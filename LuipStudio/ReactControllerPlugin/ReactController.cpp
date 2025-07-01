/**
 * @file
 * @brief 反应堆控制器。
 * @details
 * @version 1.0.0
 * @author kim@erchashu.com
 * @date 2016/5/13
 */
#include "Log.h"
#include "Communication/EventHandler.h"
#include "ReactController.h"
#include "Communication/CommunicationException.h"
#include "API/Code/OpticalAcquireInterface.h"
#include "API/Code/TemperatureControlInterface.h"
#include "LuaEngine/LuaEngine.h"
#include <QDebug>

using namespace std;
using namespace Communication;
using namespace Communication::Dscp;
using namespace OOLUA;
using namespace Lua;

namespace Controller
{

/**
 * @brief 单泵液路控制器构造。
 */
ReactController::ReactController(DscpAddress addr)
    : BaseController(addr),
    IOpticalAcquire(new OpticalAcquireInterface(addr)),
    ITemperatureControl(new TemperatureControlInterface(addr)),
    m_environmentTemp(0),m_sendEnvTempCount(0)
{
    connect(this, SIGNAL(EnvTempToLuaSignal(float)), this, SLOT(EnvTempToLuaSlot(float)));
}

ReactController::~ReactController()
{
    if (IOpticalAcquire)
        delete IOpticalAcquire;
    if (ITemperatureControl)
        delete ITemperatureControl;
}

/**
 * @brief 初始化 Controller 环境。
 */
bool ReactController::Init()
{
    IOpticalAcquire->RegisterAcquireADNotice(this);
    ITemperatureControl->RegisterTemperatureNotice(this);

    memset(&m_temperature, 0, sizeof(m_temperature));

    return true;
}

bool ReactController::Uninit()
{
    return true;
}

void ReactController::Register(ISignalNotifiable *handle)
{
    m_notifise.push_back(handle);
}

OpticalAcquireInterface *ReactController::GetIOpticalAcquire()
{
    return IOpticalAcquire;
}

TemperatureControlInterface *ReactController::GetITemperatureControl()
{
    return ITemperatureControl;
}

float ReactController::GetDigestTemperature() const
{
    return m_temperature.thermostatTemp;
}

float ReactController::GetEnvironmentTemperature() const
{
    return m_temperature.environmentTemp;
}

Temperature ReactController::GetCurrentTemperature()
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

void ReactController::OnReceive(DscpEventPtr event)
{
    switch (event->code)
    {
        case DSCP_EVENT_TCI_TEMPERATURE_NOTICE:     //温度上报事件
        {
            m_temperature.thermostatTemp = *((float*)event->data);
            m_temperature.environmentTemp = *((float*)(event->data+4));

            m_environmentTemp = m_temperature.environmentTemp;
            emit EnvTempToLuaSignal(m_environmentTemp);

            if(!m_notifise.empty())
            {
                list<ISignalNotifiable*>::iterator it;
                for(it = m_notifise.begin(); it != m_notifise.end(); it++)
                {
                    (*it)->OnSignalChanged("tTemp", m_temperature.thermostatTemp);
                    (*it)->OnSignalChanged("eTemp", m_temperature.environmentTemp);
                }
            }
        }
            break;

        case DSCP_EVENT_OAI_SIGNAL_AD_NOTICE:   // 光学测量信号AD定时上报事件
        {
            double ref0 = *((unsigned short*)(event->data));
            double mea0 = *((unsigned short*)(event->data + 2));
            double mea = *((unsigned short*)(event->data + 4)); //相反的
            double ref = *((unsigned short*)(event->data + 6));
            double abs = 0;
            if (0 < ref && 0 < mea)
            {
                abs = 1000 * log10(ref/mea);
            }

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

        default:
            break;
    }
}

void ReactController::StartSignalUpload()
{
    if (this->GetConnectStatus())
    {
        try
        {
            this->IOpticalAcquire->SetAcquireADNotifyPeriod(1);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("ReactController::StartSignalUpload() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("ReactController::StartSignalUpload() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("ReactController::StartSignalUpload() => %s", e.what());
        }
    }

    if (this->GetConnectStatus())
    {
        try
        {
            this->ITemperatureControl->SetTemperatureNotifyPeriod(1);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("ReactController::StartSignalUpload() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("ReactController::StartSignalUpload() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("ReactController::StartSignalUpload() => %s", e.what());
        }
    }
}

void ReactController::StopSignalUpload()
{
    if (this->GetConnectStatus())
    {
        try
        {
            this->IOpticalAcquire->SetAcquireADNotifyPeriod(0);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("ReactController::StopSignalUpload() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("ReactController::StopSignalUpload() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("ReactController::StopSignalUpload() => %s", e.what());
        }
    }

    if (this->GetConnectStatus())
    {
        try
        {
            this->ITemperatureControl->SetTemperatureNotifyPeriod(0);
        }
        catch(CommandTimeoutException e)
        {
            logger->warn("ReactController::StopSignalUpload() => %s", e.What().c_str());
        }
        catch(ExpectEventTimeoutException e)
        {
            logger->warn("ReactController::StopSignalUpload() => %s", e.What().c_str());
        }
        catch (std::exception e)
        {
            logger->warn("ReactController::StopSignalUpload() => %s", e.what());
        }
    }
}

void  ReactController::EnvTempToLuaSlot(float temp)
{
    m_sendEnvTempCount++;

    if (m_sendEnvTempCount >= 60)
    {
        m_sendEnvTempCount = 0;

        lua_State * newState = LuaEngine::Instance()->GetThreadState();

        OOLUA::Lua_function call(newState);
        OOLUA::Lua_func_ref recvEevTemp;

        try
        {
            if(OOLUA::get_global(newState, "RecvEevTemp", recvEevTemp))
            {
                call(recvEevTemp, temp);
            }
        }
        catch(OOLUA::Exception e)
        {
            logger->warn("CM66DriveController::EnvTempToLuaSlot() => %s", e.what());
        }
        catch(std::exception e)
        {
            logger->warn("CM66DriveController::EnvTempToLuaSlot() => %s", e.what());
        }
    }
}

}
