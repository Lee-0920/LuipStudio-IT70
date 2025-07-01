/**
 * @file
 * @brief 驱动控制器。
 * @details
 * @version 1.0.0
 * @author kim@erchashu.com
 * @date 2016/5/13
 */

#include <QTime>
#include <QThread>
#include <QDebug>
#include <QCoreApplication>
#include "Log.h"
#include "TOCDriveController.h"
#include "API/Code/OpticalMeterInterface.h"
#include "API/Code/TemperatureControlInterface.h"
#include "API/Code/PeristalticPumpInterface.h"
#include "API/TemperatureControlInterface.h"
#include "API/Code/OpticalAcquireInterface.h"
#include "Communication/EventHandler.h"
#include "Communication/CommunicationException.h"
#include "LuaEngine/LuaEngine.h"
#include "API/Code/SolenoidValveInterface.h"
#include "NT66ResultDetailPlugin//CurveManager.h"
#include <QTimer>

using namespace std;
using namespace Communication;
using namespace Communication::Dscp;

using namespace std;
using namespace Communication;
using namespace Communication::Dscp;
using namespace OOLUA;
using namespace Lua;

namespace Controller
{

/**
 * @brief 驱动控制器构造。
 */
TOCDriveController::TOCDriveController(DscpAddress addr)
    : BaseController(addr),
    IPeristalticPump(new PeristalticPumpInterface(addr)),
    ISolenoidValve(new SolenoidValveInterface(addr)),
    IOpticalMeter(new OpticalMeterInterface(addr)),
    ITemperatureControl(new TemperatureControlInterface(addr)),
    IOpticalAcquire(new OpticalAcquireInterface(addr)),
    IExtTemperatureControl(new ExtTemperatureControlInterface(addr)),
    IExtOpticalAcquire(new ExtOpticalAcquireInterface(addr)),
    m_isEnable(false),
    m_isBoxFanRunning(false),
    m_isEnableStove(true),
    m_insideEnvironmentTemp(0),
    m_ExInsideEnvironmentTemp(0),
    m_environmentTemp(0),
    m_tempMonitorControlPeriod(0),
    m_scanLen(0),
    m_stoveADValue(0),
    m_weepingDetectEnable(false),
    m_timeOutLen(0)
{
    memset(m_thermostatTempArray, 0, sizeof(m_thermostatTempArray));
    memset(m_pressureArray, 0, sizeof(m_pressureArray));
    memset(m_scanData, 0, sizeof(m_scanData));
    memset(m_MeasureTemp, 0, sizeof(m_MeasureTemp));
    memset(m_EnvTemp, 0, sizeof(m_EnvTemp));
    memset(m_pressture, 0, sizeof(m_pressture));
    try
    {
        LuaEngine* luaEngine = LuaEngine::Instance();
        lua_State * state = luaEngine->GetThreadState();
        Table configSystemTable;
        luaEngine->GetLuaValue(state, "config.system", configSystemTable);
        if(!configSystemTable.safe_at("environmentTemperature",m_insideEnvironmentTemp))
        {
            luaEngine->GetLuaValue(state, "setting.temperature.insideEnvironmentTemp", m_insideEnvironmentTemp);
        }
        if(!configSystemTable.safe_at("exEnvironmentTemperature",m_ExInsideEnvironmentTemp))
        {
            luaEngine->GetLuaValue(state, "setting.temperature.insideEnvironmentTemp", m_ExInsideEnvironmentTemp);
        }

        Table temperaturemTable;
        luaEngine->GetLuaValue(state, "setting.temperature", temperaturemTable);
        if(!temperaturemTable.safe_at("tempMonitorControlPeriod", m_tempMonitorControlPeriod))
        {
            m_tempMonitorControlPeriod = 300;
        }
        luaEngine->GetLuaValue(state, "config.system.adcDetect[1].enable", m_weepingDetectEnable);
    }
    catch(OOLUA::Exception e)
    {
        logger->warn("TOCDriveController::TOCDriveController() => %s", e.what());
    }
    catch(std::exception e)
    {
        logger->warn("TOCDriveController::TOCDriveController() => %s", e.what());
    }
    timer = new QTimer();
    m_baseLineTimer = new QTimer();
    connect(timer, SIGNAL(timeout()), this, SLOT(ThermostatMonitorSlot()));
    connect(m_baseLineTimer, SIGNAL(timeout()), this, SLOT(BaseLineStatusMonitor()));
    connect(this, SIGNAL(BoxFanControlSignal(float)), this, SLOT(BoxFanControlSlot(float)));
    connect(this, SIGNAL(ExBoxFanControlSignal(float)), this, SLOT(ExBoxFanControlSlot(float)));

    LuaEngine* luaEngine = LuaEngine::Instance();
    lua_State * state = luaEngine->GetThreadState();
    luaEngine->GetLuaValue(state, "setting.ui.runStatus.thermostatMonitor", this->thermostatFunc);
    timer->start(m_tempMonitorControlPeriod * 1000);
    m_baseLineTimer->start(5 * 1000);
}

TOCDriveController::~TOCDriveController()
{
    if (IPeristalticPump)
        delete IPeristalticPump;
    if (ISolenoidValve)
        delete ISolenoidValve;
    if (IOpticalMeter)
        delete IOpticalMeter;
    if (ITemperatureControl)
        delete ITemperatureControl;
    if (IOpticalAcquire)
        delete IOpticalAcquire;
    if (IExtTemperatureControl)
        delete IExtTemperatureControl;
    if (IExtOpticalAcquire)
        delete IExtOpticalAcquire;
}


/**
 * @brief 初始化 LiquidController 环境。
 */
bool TOCDriveController::Init()
{
    IOpticalMeter->RegisterOpticalADNotice(this);
    ITemperatureControl->RegisterTemperatureNotice(this);
    IOpticalAcquire->RegisterAcquireADNotice(this);
    ISolenoidValve->RegisterPressureNotice(this);
    IOpticalAcquire->RegisterNDIRNotice(this);
    IOpticalAcquire->RegisterAcquireCheckLeaking(this);

    return true;
}

bool TOCDriveController::Uninit()
{
    return true;
}

void TOCDriveController::Register(ISignalNotifiable *handle)
{
    m_notifise.push_back(handle);
}

PeristalticPumpInterface *TOCDriveController::GetIPeristalticPump()
{
    return IPeristalticPump;
}

SolenoidValveInterface *TOCDriveController::GetISolenoidValve()
{
    return ISolenoidValve;
}

OpticalMeterInterface *TOCDriveController::GetIOpticalMeter()
{
    return IOpticalMeter;
}

TemperatureControlInterface *TOCDriveController::GetITemperatureControl()
{
    return ITemperatureControl;
}

OpticalAcquireInterface *TOCDriveController::GetIOpticalAcquire()
{
    return IOpticalAcquire;
}

ExtTemperatureControlInterface *TOCDriveController::GetIExtTemperatureControl()
{
    return IExtTemperatureControl;
}

ExtOpticalAcquireInterface *TOCDriveController::GetIExtOpticalAcquire()
{
    return IExtOpticalAcquire;
}

float TOCDriveController::GetDigestTemperature() const
{
    return m_temperature.thermostatTemp;
}

float TOCDriveController::GetEnvironmentTemperature() const
{
    return m_temperature.environmentTemp;
}

float TOCDriveController::GetStoveADValue() const
{
    return m_stoveADValue;
}

float TOCDriveController::GetReportThermostatTemp(int index) const
{
    float temp = 0;

    if(index >= 0 && index < 3)
    {
        temp = m_thermostatTempArray[index];
    }

    return temp;
}

float TOCDriveController::GetReportEnvironmentTemp() const
{
    return m_environmentTemp;
}

float TOCDriveController::GetPressure(int index) const
{
    return m_pressureArray[index];
}

double TOCDriveController::GetScanData(int index) const
{
    if(index < DATA_MAX_LENGTH)
    {
        return m_scanData[index];
    }

    return 0;
}

int TOCDriveController::GetScanLen(void) const
{
    return m_scanLen;
}

double TOCDriveController::GetData(void)
{
    if(m_scanLen)
    {
//        qDebug("Test OK len %d, %.3f", m_scanLen, m_scanData[m_scanLen-1]);
        return  m_scanData[m_scanLen-1];
    }
    return 0;
}

void TOCDriveController::ClearBuf(void)
{
    memset(m_scanData, 0, sizeof(m_scanData));
    memset(m_MeasureTemp, 0, sizeof(m_MeasureTemp));
    memset(m_EnvTemp, 0, sizeof(m_EnvTemp));
    memset(m_pressture, 0, sizeof(m_pressture));
    m_scanLen = 0;
}

double TOCDriveController::NDIRResultHandle(int startIndex, int endIndex, int validCnt,
                                            int step, int increment,
                                            int filterStep, int throwNum) const
{
    //    //刷新频率必须与上报频率一致
    double minDeviation, endDeviation;
//    int filterStep = 0;
    bool debugMode;
    LuaEngine* luaEngine = LuaEngine::Instance();
    lua_State * state = luaEngine->GetThreadState();
    Table measureResultTable, configSystemTable;
    luaEngine->GetLuaValue(state, "setting.measureResult", measureResultTable);
    measureResultTable.safe_at("minDeviation", minDeviation);
    measureResultTable.safe_at("endDeviation", endDeviation);
//    measureResultTable.safe_at("filterStep", filterStep);
    luaEngine->GetLuaValue(state, "config.system", configSystemTable);
    configSystemTable.safe_at("debugMode",debugMode);

    int maxIndex = 0;

    //五阶中值滤波
    double filterbuffer[endIndex - startIndex] = {0};//={0};
    int length = endIndex - startIndex;
    Filter(&m_scanData[startIndex], &filterbuffer[0], length, filterStep, throwNum);

    for(int i = 0; i < length; i++) //全部取负，得到正峰
    {
       filterbuffer[i] = 0 - filterbuffer[i];
       if(i > 20+filterStep*2 && i < length - 20-filterStep*2)
       {
           if(debugMode)
           {
               logger->debug("Filter[%d]: %f, NDIR: %f , Env: %f, Pre: %f",
                             i, filterbuffer[i], m_MeasureTemp[startIndex+i], m_EnvTemp[startIndex+i], m_pressture[startIndex+i]);
           }
       }
    }

    double min = filterbuffer[50], max = -100;
    for(int i = 20+filterStep*2; i < length - 50-filterStep*2 ; i++) //寻找峰最大值，及其索引值
    {
       if(max < filterbuffer[i]
               && (fabs(filterbuffer[i] - filterbuffer[i-10]) < 0.1)
               && (fabs(filterbuffer[i] - filterbuffer[i+10]) < 0.1))
       {
           max = filterbuffer[i];
           maxIndex = i;
       }
    }

    if (maxIndex == 0 )
    {
        maxIndex = length/2;
        logger->warn("maxIndex error");
    }

    int leftIndex = 20+filterStep*2, rightIndex = length - 30- filterStep*2;
    //从峰最低点往后寻找起始点, 连续十个点的极差值小于偏差范围则认为稳定
    double divation;
    bool isFinish = false;
    int finishCnt = 0;
    int endValidCnt = 0;
    float decimal = (int)((float)validCnt*0.8*10)%10;
    if(decimal >= 5)
    {
        endValidCnt = (int)((float)validCnt*0.8)+1;
    }
    else
    {
        endValidCnt = (int)((float)validCnt*0.8);
    }

    int tempIndex = maxIndex;
    for(int i = maxIndex - 50; i > 50+validCnt*increment; i -= increment)
    {

       min = filterbuffer[i];
       max = filterbuffer[i-validCnt*increment];

       divation = fabs(max - min);
    //           qDebug("divation: %f", divation);
       if(divation <= minDeviation*1.5 && i < maxIndex - increment*10)
       {
           for(int j = i; j > i - validCnt*increment; j -= increment)
           {
               double subMin = filterbuffer[j];
               double subMax = filterbuffer[j-step];

               divation = fabs(subMax - subMin);
               qDebug("divation-: %f", divation);
               if(divation <= minDeviation)
               {
                   finishCnt++;
               }
               if(maxIndex == 20)  //数据异常
               {
                   break;
               }
               if(finishCnt >= endValidCnt)
               {
                   leftIndex = j + increment*6;
                   break;
               }
           }

       }

       if(finishCnt >= endValidCnt)
       {
           qDebug("finish: %d, minDeviation: %f", leftIndex, minDeviation);
           break;
       }
       else
       {
           finishCnt = 0;
       }
    }
    if(finishCnt < endValidCnt)
    {
      leftIndex = 20+filterStep*2;
    }

    finishCnt = 0;
    tempIndex = maxIndex +increment*10;
    for(int i = maxIndex + increment*10; i < length - 30- validCnt*increment; i += increment)
    {
     min = filterbuffer[i];
     max = filterbuffer[i+validCnt*increment];
     divation = fabs(max - min);
    //         qDebug("divation: %f", divation);
     if(divation <= endDeviation*1.5 && i > maxIndex + increment*10)
     {
         for(int j = i; j < i + validCnt*increment; j += increment)
         {
             double subMin = filterbuffer[j];
             double subMax = filterbuffer[j-step];

             divation = fabs(subMax - subMin);
             if(divation <= minDeviation)
             {
                 finishCnt++;
             }
             if(finishCnt >= endValidCnt)
             {
                 rightIndex = j - increment*6;
                 break;
             }
         }
     }

     if(finishCnt >= endValidCnt)
     {
         qDebug("finish: %d, minDeviation: %f", rightIndex, endDeviation);
         qDebug("reset+: %d, %d", tempIndex, i);
         break;
     }
     else
     {
         finishCnt = 0;
     }

    }
    if(finishCnt < endValidCnt) //异常处理
    {
      rightIndex = length - 30-filterStep*2;
    }    

     //异常判定
      if(leftIndex < 20+filterStep*2 )
     {
         leftIndex = 30+filterStep*2;
     }

     if(rightIndex < maxIndex)
     {
         rightIndex = length - 30-filterStep*2;
     }

     //限制右侧半峰宽度
     if(abs(rightIndex-maxIndex)> abs(maxIndex-leftIndex)*2.2)
     {
        logger->debug("recalculate index: %d", rightIndex);
        rightIndex = (int)(maxIndex-leftIndex)*2.2 + maxIndex;
        if(rightIndex > length - 30-filterStep*2)
        {
            rightIndex = length - 30-filterStep*2;
            logger->debug("out of length");
        }
     }

     if(maxIndex > (length*0.9))
     {
        leftIndex = (int)(0.05*length);
        rightIndex = (int)(0.4*length);
     }

     //起始结束点取10点为平均
     double averValueStart, averValueEnd , averSum = 0;
     double maxVlaue =0, minValue =0;
     maxVlaue = filterbuffer[leftIndex + filterStep ];
     minValue = filterbuffer[leftIndex + filterStep ];
     for(int i = leftIndex - filterStep;i < leftIndex + filterStep+1; i++)
     {
         if(minValue > filterbuffer[i])
         {
             minValue = filterbuffer[i];
         }
         if(maxVlaue < filterbuffer[i])
         {
             maxVlaue = filterbuffer[i];
         }
         averSum += filterbuffer[i];
     }

     averValueStart = (averSum - minValue - maxVlaue)/(filterStep*2-1);

     maxVlaue = filterbuffer[rightIndex - filterStep ];
     minValue = filterbuffer[rightIndex - filterStep ];
     averSum = 0;
     for(int i = rightIndex - filterStep;i < rightIndex + filterStep+1; i++)
     {
         if(minValue > filterbuffer[i])
         {
             minValue = filterbuffer[i];
         }
         if(maxVlaue < filterbuffer[i])
         {
             maxVlaue = filterbuffer[i];
         }
         averSum += filterbuffer[i];
     }

      averValueEnd = (averSum - minValue - maxVlaue)/(filterStep*2-1);

//      averValueEnd = (averValueEnd - averValueStart)/2 + averValueStart;

       logger->debug("averValueStart: %f, averValueEnd: %f, filterStep: %d, validCnt: %d, increment: %d, filterStep: %d, throwNum: %d",
                     averValueStart, averValueEnd, filterStep, validCnt, increment, filterStep ,throwNum);
       logger->debug("startDeviation: %f, endDeviation: %f", minDeviation, endDeviation);
       logger->debug("leftIndex: %d, rightIndex: %d , length: %d, maxIndex: %d, maxVlue: %f, minDeviation: %f",
                     leftIndex, rightIndex, length, maxIndex, filterbuffer[maxIndex], minDeviation);
       /* 基线相对信号计算 Start */
       int baseLen =  rightIndex-leftIndex;
       double baseK = (averValueEnd-averValueStart)/baseLen;
       double baseB = averValueStart;
       double baseSum = 0;
       double baseData[baseLen];
       for(int i = 0; i < baseLen; i++)
       {
           double baseTemp = i*baseK+baseB;
           baseData[i] = log10(baseTemp/filterbuffer[i+leftIndex]) ;
           baseSum += baseData[i];
   //        qDebug("baseData[%d] = %.8f", i, baseData[i]);
       }
       baseSum = baseSum*10;
       logger->debug("baseK: %.8f, baseB: %.8f", baseK, baseB);
        /* 基线相对信号计算 End */

        //求峰宽，峰高
       int validLen = rightIndex - leftIndex + 1;
       double validHigh = filterbuffer[maxIndex] -
               (filterbuffer[rightIndex-1] + filterbuffer[rightIndex] + filterbuffer[rightIndex+1]
               + filterbuffer[leftIndex-1] + filterbuffer[leftIndex] + filterbuffer[leftIndex+1])/6;

       //求峰宽系数
        int scaleNum = 500; //
       double peakWideFactor = (double)1 / scaleNum;

       //求值S1，S2
       double S1 = 0, S2 = 0, midSum = 0;

       int scale = scaleNum;

       int cnt = 1;
       for(int i = leftIndex; i < rightIndex + 1; i++)
       {
           double scaleSum = 0;
           int localCnt = 1;
           midSum += filterbuffer[i];
       }

       S1 = midSum;
       S2 = (double) (averValueEnd + averValueStart)/2 * validLen;

       double areaSum = 0;
       areaSum = S1 - S2;

       validHigh = validHigh*1000;
//       double leftHight = fabs(averValueStart-filterbuffer[maxIndex]);
//       double rightHight = fabs(averValueEnd-filterbuffer[maxIndex]);
//       if(leftHight<=0.0015 || rightHight<=0.0015)
//       {
//           logger->debug("leftHight: %f, rightHight: %f", leftHight, rightHight);
//           baseSum = 0;
//       }
       logger->debug("S1: %f, S2: %f", S1, S2);
       logger->debug("left: %f, right: %f, validLen: %d ", filterbuffer[leftIndex], filterbuffer[rightIndex], validLen);
       logger->debug("baseSum: %.8f, sum: %f ,high: %f , step: %d, R30", baseSum, areaSum, validHigh, step);

       return baseSum;


}

bool TOCDriveController::IsReachSteady(int num, int validCnt, int step, int increment, int filterStep, int throwNum, int index) const
{
    if(m_scanLen < num )
    {
        return false;
    }
    //    //刷新频率必须与上报频率一致
    double minDeviation, endDeviation, deviation;
    bool debugMode;
    LuaEngine* luaEngine = LuaEngine::Instance();
    lua_State * state = luaEngine->GetThreadState();
    Table measureResultTable, configSystemTable;
    luaEngine->GetLuaValue(state, "setting.measureResult", measureResultTable);
    measureResultTable.safe_at("deviation", deviation);
    measureResultTable.safe_at("minDeviation", minDeviation);
    measureResultTable.safe_at("endDeviation", endDeviation);
    luaEngine->GetLuaValue(state, "config.system", configSystemTable);
    configSystemTable.safe_at("debugMode",debugMode);

    int maxIndex = 0;

    //五阶中值滤波
    double filterbuffer[num] = {0};//={0};
    int length = num;
    Filter(&m_scanData[m_scanLen-length], &filterbuffer[0], length, filterStep, throwNum);

    for(int i = 0; i < length; i++) //全部取负，得到正峰
    {
       filterbuffer[i] = 0 - filterbuffer[i];
    }

    //终点判定
    double divation, max, min;
    bool isFinish = false;
    int finishCnt = 0;
    int tempIndex = length - step;

    //极差值判定方式
    if(index == 0)
    {
        double checkDeviation;
        if(m_scanLen < num)
        {
            qDebug("NDIR len error");
            return false;
        }

        for(int i = 0; i < length; i++) //全部取负，得到正峰
        {
           filterbuffer[i] = 0 - filterbuffer[i];
        }

        //倒序寻找并比较
        int minIndex = m_scanLen - 1;  //减去数组未装填的指针地址
        int endIndex = minIndex - num;  //连续10个数据在波动范围内则认为稳定

        double min = filterbuffer[filterStep*2];
        double max = filterbuffer[filterStep*2];
        double k1,k2;
        for(int i = filterStep*2; i < length - filterStep*2; i++)
        {
            if(min > filterbuffer[i])
            {
                min = filterbuffer[i];
            }
            if(max < filterbuffer[i])
            {
                max = filterbuffer[i];
            }
//            logger->debug("check fbuf[%d]:%f", i, fbuf[i]);
        }
        k1 = filterbuffer[num/2] - filterbuffer[filterStep*2];
        k2 = filterbuffer[num- filterStep*2-1] - filterbuffer[num/2];
        checkDeviation = fabs(max - min);
        qDebug("check: %f, deviation:%f , max: %f, min: %f, k1: %f, k2:%f , sub: %f",
               checkDeviation, deviation, max, min, k1, k2, k2-k1);
        if(checkDeviation < deviation && checkDeviation > 0.000001)
        {
//            logger->debug("check divation: %f ", divation);
            return true;
        }
        else if(abs(k2 - k1) < 0.0001 && checkDeviation < deviation*3)
        {
             qDebug("k1: %f, k2:%f , sub: %f", k1, k2, k2-k1);
             return true;
        }
        return false;
    }
    else //连续判定方式
    {
        for(int i = length - step; i > step; i -= increment)
        {
           min = filterbuffer[i];
           max = filterbuffer[i-step];
           divation = fabs(max - min);
           if(divation <= minDeviation)
           {
               finishCnt++;
               if(abs(tempIndex-i)>increment*2 && finishCnt > 1) //判断是否为连续
               {
                   finishCnt = 0;
               }
               tempIndex = i;
           }

           if(finishCnt >= validCnt)
           {
               qDebug("finish: %f", minDeviation);
               return true;
           }
        }

        return false;
    }
}

Temperature TOCDriveController::GetCurrentTemperature()
{
    Temperature temp = {0, 0};

    try
    {
        temp = this->ITemperatureControl->GetTemperature();
    }
    catch (CommandTimeoutException e)  // 命令应答超时异常。
    {
        if(this->GetConnectStatus())
        {
            memcpy(&temp, &m_temperature, sizeof(Temperature));
        }
        else
        {
            throw CommandTimeoutException(e.m_addr, e.m_code);
        }
    }
    catch (std::exception e)
    {
        if(this->GetConnectStatus())
        {
            memcpy(&temp, &m_temperature, sizeof(Temperature));
        }
        else
        {
            throw std::exception();
        }
    }

    return temp;
}
void TOCDriveController::TempMonitor(void)
{
    int indexStove;
    float reactTemperature;
    float toleranceTemp;
    float reactTempTimeout;

    int indexRefrigerator;
    float coolTemperature;
    float coolToleranceTemp;
    float coolTempTimeout;

    int indexNDIR;
    float measureModuleTemperature;
    float NDIRToleranceTemp;
    float NDIRTempTimeout;

    //温度监测
    LuaEngine* luaEngine = LuaEngine::Instance();
    lua_State * state = luaEngine->GetThreadState();

    Table measureParamTable, temperatureTable;
    luaEngine->GetLuaValue(state, "config.measureParam", measureParamTable);
    luaEngine->GetLuaValue(state, "setting.temperature", temperatureTable);

    measureParamTable.safe_at("reactTemperature", reactTemperature);
    temperatureTable.safe_at("indexStove", indexStove);
    temperatureTable.safe_at("toleranceTemp", toleranceTemp);
    temperatureTable.safe_at("reactTempTimeout", reactTempTimeout);

    measureParamTable.safe_at("coolTemperature", coolTemperature);
    temperatureTable.safe_at("indexRefrigerator", indexRefrigerator);
    temperatureTable.safe_at("coolToleranceTemp", coolToleranceTemp);
    temperatureTable.safe_at("coolTempTimeout", coolTempTimeout);

    measureParamTable.safe_at("measureModuleTemperature", measureModuleTemperature);
    temperatureTable.safe_at("indexNDIR", indexNDIR);
    temperatureTable.safe_at("NDIRToleranceTemp", NDIRToleranceTemp);
    temperatureTable.safe_at("NDIRTempTimeout", NDIRTempTimeout);

//    qDebug("%d, %f, %f, %f", indexStove, reactTemperature, toleranceTemp, reactTempTimeout);
//    qDebug("%d, %f, %f, %f", indexRefrigerator, coolTemperature, coolToleranceTemp, coolTempTimeout);
//    qDebug("%d, %f, %f, %f", indexNDIR, measureModuleTemperature, NDIRToleranceTemp, NDIRTempTimeout);


        //燃烧炉监测
        if((fabs(m_temperature.thermostatTemp - reactTemperature) > 15))
        {
            if(((m_temperature.thermostatTemp - reactTemperature) < -15))//温度过冲后，低温重新打开电炉电源
            {
                ITemperatureControl->RelayControlForTOC(1);
            }
            if(ITemperatureControl->GetThermostatStatus()== 1)
            {
                qDebug("therm idle: %d", indexStove);
            }
            else
            {
                ITemperatureControl->StopThermostat();
            }
            ITemperatureControl->ReviseThermostatTemp(indexStove, (ThermostatMode)1, reactTemperature, toleranceTemp, reactTempTimeout);
            logger->debug("Current Tempperature: %f", m_temperature.thermostatTemp);
        }

        //制冷器监测
        if((fabs(m_thermostatTempArray[0] - coolTemperature) > 2))
        {
            if(IExtTemperatureControl->GetThermostatStatus(indexRefrigerator)== 1)
            {
                qDebug("therm idle: %d", indexRefrigerator);
            }
            else
            {
               IExtTemperatureControl->StopThermostat(indexRefrigerator, false);
            }
            ITemperatureControl->ReviseThermostatTemp(indexRefrigerator, (ThermostatMode)2, coolTemperature, coolToleranceTemp, coolTempTimeout);
            logger->debug("Current Tempperature: %f", m_thermostatTempArray[0]);
        }

        //NDIR监测
        if((fabs(m_thermostatTempArray[1] - measureModuleTemperature) > (NDIRToleranceTemp*5)))
        {
            if(IExtTemperatureControl->GetThermostatStatus(indexNDIR)== 1)
            {
                qDebug("therm idle: %d", indexNDIR);
            }
            else
            {
               IExtTemperatureControl->StopThermostat(indexNDIR, false);
            }
            ITemperatureControl->ReviseThermostatTemp(indexNDIR, (ThermostatMode)1, measureModuleTemperature, NDIRToleranceTemp, NDIRTempTimeout);
        }


}

void TOCDriveController::ThermostatMonitorSlot(void)
{
    try
    {
        lua_State * newState = LuaEngine::Instance()->GetThreadState();
        OOLUA::Lua_function call(newState);
        call(this->thermostatFunc);
    }
    catch(OOLUA::Exception e)
    {
        logger->warn("TOCDriveController::ThermostatMonitorSlot() => %s", e.what());
    }
    catch(std::exception e)
    {
        logger->warn("TOCDriveController::ThermostatMonitorSlot() => %s", e.what());
    }
}

void TOCDriveController::OnReceive(DscpEventPtr event)
{
    static int count = 0;
//    logger->debug("\n get event code = %d",event->code);
    switch (event->code)
    {
        case DSCP_EVENT_OMI_OPTICAL_AD_NOTICE:      //光学定量信号AD上报
        {
            Uint8 num = *(event->data);
            Uint32 adValue[num];

            for(Uint8 i = 0; i < num; i++)
            {
                adValue[i] = *((Uint32*)(event->data+1 + i*4));
            }

            if(!m_notifise.empty())
            {
                list<ISignalNotifiable*>::iterator it;
                for(it = m_notifise.begin(); it != m_notifise.end(); it++)
                {
                    for(Uint8 i = 0; i < num; i++)
                    {
                        String str = "mp" + std::to_string(i + 1) + "AD";
                        (*it)->OnSignalChanged(str, adValue[i]);
                    }
                }
            }
        }
            break;

        case DSCP_EVENT_TCI_TEMPERATURE_NOTICE:     //温度上报事件
        {
            m_temperature.thermostatTemp = *((float*)event->data);
            m_temperature.environmentTemp = *((float*)(event->data+4));

            m_environmentTemp = *((float*)(event->data+4));
            if(event->len >= 12)
            {
                m_thermostatTempArray[0] = *((float*)(event->data+8));
            }
            if(event->len >= 16)
            {
                m_thermostatTempArray[1] = *((float*)(event->data+12));
            }
            if(event->len >= 20)
            {
                m_thermostatTempArray[2] = *((float*)(event->data+16));
            }
            if(event->len >= 24)
            {
                m_stoveADValue = *((float*)(event->data+20));
            }

            emit BoxFanControlSignal(m_temperature.environmentTemp);
            emit ExBoxFanControlSignal(m_thermostatTempArray[2]);

            if(!m_notifise.empty())
            {
                list<ISignalNotifiable*>::iterator it;
                for(it = m_notifise.begin(); it != m_notifise.end(); it++)
                {
                    (*it)->OnSignalChanged("tTemp", m_temperature.thermostatTemp);
                    (*it)->OnSignalChanged("eTemp", m_environmentTemp);
                    (*it)->OnSignalChanged("tTemp1", m_thermostatTempArray[0]);
                    (*it)->OnSignalChanged("tTemp2", m_thermostatTempArray[1]);
                    (*it)->OnSignalChanged("tTemp3", m_thermostatTempArray[2]);
                    (*it)->OnSignalChanged("eStoveAD", m_stoveADValue);
                }
            }
        }

            break;

        case DSCP_EVENT_OAI_SIGNAL_AD_NOTICE:   // 光学测量信号AD定时上报事件
        {
            double ref = *((Uint32*)(event->data));
            double mea = *((Uint32*)(event->data + 4));
            double abs = 0;
            if (0 < ref && 0 < mea)
            {
                abs = 1000 * log10(ref/mea);
            }
            mea = mea/1000000;
            ref = ref/1000000;

            if(!m_notifise.empty())
            {
                list<ISignalNotifiable*>::iterator it;
                for(it = m_notifise.begin(); it != m_notifise.end(); it++)
                {
                    (*it)->OnSignalChanged("refAD", ref);
                    (*it)->OnSignalChanged("meaAD", mea);
                    (*it)->OnSignalChanged("abs", abs);
                }
            }
        }
            break;
        case DSCP_EVENT_SVI_PREESURE_NOTICE:      //压力传感器值上报 0-2
        {
//            logger->debug("\n event is DSCP_EVENT_SVI_PREESURE_NOTICE");
            Uint8 num = *(event->data);
            float adValue[num];

            for(Uint8 i = 0; i < num; i++)
            {
                adValue[i] = *((float*)(event->data+1 + i*4));
                m_pressureArray[i] = adValue[i];
            }

            if(!m_notifise.empty())
            {
                list<ISignalNotifiable*>::iterator it;
                for(it = m_notifise.begin(); it != m_notifise.end(); it++)
                {
                    for(Uint8 i = 0; i < num; i++)
                    {
                        String str = "pSensor" + std::to_string(i + 1);
                        (*it)->OnSignalChanged(str, adValue[i]);
                    }
                }
            }
        }
            break;
        case DSCP_EVENT_OAI_REPORT_DATA:   // NDIR测量值定时上报事件
        {
            m_scanData[m_scanLen] = *((float*)(event->data));
            m_MeasureTemp[m_scanLen] = m_thermostatTempArray[1];  //温度补偿跟踪
            m_EnvTemp[m_scanLen] = m_temperature.environmentTemp;  //环境温度跟踪
            m_pressture[m_scanLen] = m_pressureArray[2];    //载气压力跟踪
            m_scanLen++;   //勿在定时器中修改索引
            if(m_scanLen > DATA_MAX_LENGTH-1)
            {
                m_scanLen = 0;
                memset(m_scanData, 0, sizeof(m_scanData));
                memset(m_MeasureTemp, 0, sizeof(m_MeasureTemp));
                memset(m_EnvTemp, 0, sizeof(m_EnvTemp));
                memset(m_pressture, 0, sizeof(m_pressture));
            }
            m_timeOutLen = m_scanLen;

        }
            break;
        case DSCP_EVENT_DSI_CHECK_LEAKING_NOTICE:   // 漏液检测AD定时上报事件
           {
               if (m_weepingDetectEnable)
               {
                   Uint16 checkLeakingValve = *((Uint16*)(event->data));
                   Script *lua = LuaEngine::Instance()->GetEngine();
                   Table table, itermsTable;
                   itermsTable.bind_script(*lua);
                   itermsTable.set_table("setting");
                   itermsTable.at("ui", table);
                   table.at("runStatus", itermsTable);

                   Lua_func_ref func;
                   if (itermsTable.safe_at("WeepingDetectHandle", func))
                   {
                       lua->call(func,checkLeakingValve);
                   }
               }
           }
           break;
        default:
            break;
    }
}

void TOCDriveController::StopSignalUpload()
{
    if (this->GetConnectStatus())
    {
        //重置光学定量AD上传周期
        try
        {

            this->IOpticalMeter->SetOpticalADNotifyPeriod(0);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.what());
        }

        //重置温度上传周期
        try
        {
            this->ITemperatureControl->SetTemperatureNotifyPeriod(0);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.what());
        }

        //重置信号AD上传周期
        try
        {
            this->IOpticalAcquire->SetAcquireADNotifyPeriod(0);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.what());
        }
    }
}

void TOCDriveController::SetStoveEnable(bool enable)
{
     m_isEnableStove = enable;
}

void TOCDriveController::SetBoxFanEnable(bool enable)
{
    m_isEnable = enable;
    if(enable)
    {
        m_isBoxFanRunning = false;
    }
}

void TOCDriveController::BoxFanControlSlot(float temp)
{
    if (m_isEnable && m_insideEnvironmentTemp > 0.1)
   {
        if (temp - m_insideEnvironmentTemp > 0.1)
        {
           ITemperatureControl->BoxFanSetOutputForTOC(1, 1); //打开上机箱风扇
//           ITemperatureControl->BoxFanSetOutputForTOC(0, 1); //打开上机箱风扇
           m_isBoxFanRunning = true;
    //       logger->debug("打开机箱风扇");
        }
        else if (m_insideEnvironmentTemp - temp > 0.5)
        {
            ITemperatureControl->BoxFanSetOutputForTOC(1, 0); //关上机箱风扇
//            ITemperatureControl->BoxFanSetOutputForTOC(0, 0); //关下机箱风扇
           m_isBoxFanRunning = false;
    //       logger->debug("关闭机箱风扇");
        }
    }
}

void TOCDriveController::ExBoxFanControlSlot(float temp)
{
    if (m_isEnable && m_ExInsideEnvironmentTemp > 0.1)
   {
        if (temp - m_ExInsideEnvironmentTemp > 0.1)
        {
//           ITemperatureControl->BoxFanSetOutputForTOC(1, 1); //打开上机箱风扇
           ITemperatureControl->BoxFanSetOutputForTOC(0, 1); //打开下机箱风扇
           m_isBoxFanRunning = true;
    //       logger->debug("打开机箱风扇");
        }
        else if (m_ExInsideEnvironmentTemp - temp > 0.5)
        {
//            ITemperatureControl->BoxFanSetOutputForTOC(1, 0); //关上机箱风扇
            ITemperatureControl->BoxFanSetOutputForTOC(0, 0); //关下机箱风扇
           m_isBoxFanRunning = false;
    //       logger->debug("关闭机箱风扇");
        }
    }
}

void TOCDriveController::StartSignalUpload()
{
    if (this->GetConnectStatus())
    {
        //重置光学定量AD上传周期
        try
        {

            this->IOpticalMeter->SetOpticalADNotifyPeriod(1);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("TOCDriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("TOCDriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("TOCDriveController::ResetHandler() => %s", e.what());
        }

        //重置温度上传周期
        try
        {
            this->ITemperatureControl->SetTemperatureNotifyPeriod(1);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("TOCDriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("TOCDriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("TOCDriveController::ResetHandler() => %s", e.what());
        }

        //重置电极AD上传周期
        try
        {
            this->IOpticalAcquire->SetAcquireADNotifyPeriod(1);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("DriveController::ResetHandler() => %s", e.what());
        }
    }
}

void TOCDriveController::ClearThermostatRemainEvent()const
{
    logger->debug("{ClearThermostatRemainEvent}");
    try
    {
        DscpAddress addr = ITemperatureControl->GetAddress();
        for (int i = 0; i < 10; i++)
        {
            EventHandler::Instance()->Expect(addr,DSCP_EVENT_TCI_THERMOSTAT_RESULT, 200);
        }
    }
    catch(CommandTimeoutException e)
    {
    }
    catch(ExpectEventTimeoutException e)
    {
    }
    catch (std::exception e)
    {

    }
}

void TOCDriveController::ClearPumpRemainEvent()const
{
    logger->debug("{ClearPumpRemainEvent}");
    try
    {
        DscpAddress addr = IPeristalticPump->GetAddress();
        for (int i = 0; i < 10; i++)
        {
            EventHandler::Instance()->Expect(addr,DSCP_EVENT_PPI_PUMP_RESULT, 200);
        }
    }
    catch(CommandTimeoutException e)
    {
    }
    catch(ExpectEventTimeoutException e)
    {
    }
    catch (std::exception e)
    {

    }
}

void TOCDriveController::ClearAllRemainEvent()const
{
    logger->debug("{ClearAllRemainEvent}");
    EventHandler::Instance()->EmptyEvents();    //清空事件池
}


void TOCDriveController::Filter(const double *buf, double *fbuf, int length, int filterStep, int throwNum)const
{
    double averBuf[filterStep*2];

    for (int i = filterStep; i < length - filterStep; ++i)
    {
        double sum = 0;
        for(int j =0 ;j< filterStep*2-1;j++) //滤波数组赋值
        {
            averBuf[j] = buf[j+i-filterStep];
        }
        for(int j =0 ;j< filterStep*2-1;j++) //滤波数组冒泡排序
        {
            for(int k =0 ;k< filterStep*2-j-1;k++)
            {
                if(averBuf[k+1]< averBuf[k]) //正序
                {
                    double temp = averBuf[k+1];
                    averBuf[k+1] = averBuf[k];
                    averBuf[k] = temp;
                }
            }
        }

        for(int i = 0; i<filterStep*2-1;i++)
        {
            if(i>=throwNum && i < filterStep*2-throwNum) //过滤前后各4个
            {
                sum +=  averBuf[i];
            }
        }
        fbuf[i] = sum/(filterStep*2-throwNum*2);

    }
}

void TOCDriveController::BaseLineStatusMonitor()
{
    int dataNum, LEDPeriod, step, filterStep, throwNum;
    LuaEngine* luaEngine = LuaEngine::Instance();
    lua_State * state = luaEngine->GetThreadState();
    luaEngine->GetLuaValue(state, "config.hardwareConfig.measureLed.period.real", LEDPeriod);

    Table measureResultTable;
    luaEngine->GetLuaValue(state, "setting.measureResult", measureResultTable);
    measureResultTable.safe_at("filterStep", filterStep);
    measureResultTable.safe_at("throwNum", throwNum);
    dataNum = (int)((120.0)/((float)LEDPeriod/1000)); //2分钟数据
    step = (int)((10.0)/((float)LEDPeriod/1000));//10秒数据
//    qDebug("num %d, period = %d, %d, %d", dataNum, LEDPeriod, filterStep, throwNum);
    bool ret = false;
    if(m_scanLen > dataNum)
    {
        if(m_timeOutLen != m_scanLen)
        {
            m_timeOutLen = 0;
            qDebug("unsync");
            return ;
        }
        if(true == this->IsReachSteady(dataNum,15,45,step,filterStep,throwNum,0))
        {
            ret = true;
        }
        else
        {
            ret = false;
        }
        Lua_func_ref func;
        OOLUA::Script *lua = luaEngine->GetEngine();;
        Table runstatusTable;
        luaEngine->GetLuaValue(state, "setting.ui.runStatus", runstatusTable);
        if (runstatusTable.safe_at("setBaseLineStatus", func))
        {
            lua->call(func,ret);
        }
    }
}

}
