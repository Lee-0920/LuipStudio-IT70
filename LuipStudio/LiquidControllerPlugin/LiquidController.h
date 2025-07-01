/**
 * @file
 * @brief 液路控制器。
 * @details 
 * @version 1.0.0
 * @author kim@erchashu.com
 * @date 2016/5/13
 */


#if !defined(CONTROLLER_LIQUIDCONTROLNET_H_)
#define CONTROLLER_LIQUIDCONTROLNET_H_

#include <vector>
#include <QObject>
#include "LuipShare.h"
#include "ControllerPlugin/BaseController.h"
#include "API/PeristalticPumpInterface.h"
#include "API/SolenoidValveInterface.h"
#include "API/OpticalMeterInterface.h"

using std::list;

namespace Controller
{

/**
 * @brief 液路控制器。
 * @details
 */
class LUIP_SHARE LiquidController : public QObject, public BaseController
{
    Q_OBJECT

public:
    LiquidController(DscpAddress addr);
    virtual ~LiquidController();
    bool Init();
    bool Uninit();

    PeristalticPumpInterface* GetIPeristalticPump();
    SolenoidValveInterface* GetISolenoidValve();
    OpticalMeterInterface* GetIOpticalMeter();

    // ---------------------------------------
    // IEventReceivable 接口
    void Register(ISignalNotifiable *handle);
    virtual void OnReceive(DscpEventPtr event);

    void StartSignalUpload();
    void StopSignalUpload();
public:
    // 设备接口集
    PeristalticPumpInterface * const IPeristalticPump;
    SolenoidValveInterface * const ISolenoidValve;
    OpticalMeterInterface * const IOpticalMeter;

private:
    list<ISignalNotifiable*> m_notifise;

};

}

#endif  //CONTROLLER_LIQUIDCONTROLNET_H_
