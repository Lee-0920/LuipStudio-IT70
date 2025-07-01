/****************************************************************************
** Meta object code from reading C++ file 'WqimcManager.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/Interface/Wqimc/WqimcManager.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'WqimcManager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Interface__Wqimc__WqimcManager_t {
    QByteArrayData data[70];
    char stringdata0[1484];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Interface__Wqimc__WqimcManager_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Interface__Wqimc__WqimcManager_t qt_meta_stringdata_Interface__Wqimc__WqimcManager = {
    {
QT_MOC_LITERAL(0, 0, 30), // "Interface::Wqimc::WqimcManager"
QT_MOC_LITERAL(1, 31, 10), // "InitSignal"
QT_MOC_LITERAL(2, 42, 0), // ""
QT_MOC_LITERAL(3, 43, 20), // "UpdateConfigsSignals"
QT_MOC_LITERAL(4, 64, 51), // "std::vector<Interface::Wqimc:..."
QT_MOC_LITERAL(5, 116, 6), // "config"
QT_MOC_LITERAL(6, 123, 24), // "UploadMeasureDataSignals"
QT_MOC_LITERAL(7, 148, 43), // "Interface::Wqimc::Api::Manage..."
QT_MOC_LITERAL(8, 192, 4), // "data"
QT_MOC_LITERAL(9, 197, 25), // "UploadMeasureCurveSignals"
QT_MOC_LITERAL(10, 223, 44), // "Interface::Wqimc::Api::Manage..."
QT_MOC_LITERAL(11, 268, 5), // "curve"
QT_MOC_LITERAL(12, 274, 27), // "UploadReagentProfileSignals"
QT_MOC_LITERAL(13, 302, 26), // "UpdateReagentRemainSignals"
QT_MOC_LITERAL(14, 329, 58), // "std::vector<Interface::Wqimc:..."
QT_MOC_LITERAL(15, 388, 17), // "reagentRemainList"
QT_MOC_LITERAL(16, 406, 30), // "UploadConsumableProfileSignals"
QT_MOC_LITERAL(17, 437, 27), // "SetSignalUpdateCycleSignals"
QT_MOC_LITERAL(18, 465, 8), // "cycleSec"
QT_MOC_LITERAL(19, 474, 13), // "RebootSignals"
QT_MOC_LITERAL(20, 488, 14), // "UpgradeSignals"
QT_MOC_LITERAL(21, 503, 14), // "System::String"
QT_MOC_LITERAL(22, 518, 3), // "url"
QT_MOC_LITERAL(23, 522, 12), // "AlarmSignals"
QT_MOC_LITERAL(24, 535, 37), // "Interface::Wqimc::Api::Manage..."
QT_MOC_LITERAL(25, 573, 5), // "alarm"
QT_MOC_LITERAL(26, 579, 19), // "UpdateStatusSignals"
QT_MOC_LITERAL(27, 599, 38), // "Interface::Wqimc::Api::Manage..."
QT_MOC_LITERAL(28, 638, 6), // "status"
QT_MOC_LITERAL(29, 645, 19), // "UpdateActionSignals"
QT_MOC_LITERAL(30, 665, 6), // "action"
QT_MOC_LITERAL(31, 672, 28), // "NotifyDiagnosisResultSignals"
QT_MOC_LITERAL(32, 701, 47), // "Interface::Wqimc::Api::Manage..."
QT_MOC_LITERAL(33, 749, 6), // "result"
QT_MOC_LITERAL(34, 756, 29), // "CalibrationTouchScreenSignals"
QT_MOC_LITERAL(35, 786, 16), // "UpLoadFileSignal"
QT_MOC_LITERAL(36, 803, 18), // "DownloadFileSignal"
QT_MOC_LITERAL(37, 822, 26), // "ChangeHardwareParamSignals"
QT_MOC_LITERAL(38, 849, 36), // "Interface::Wqimc::Api::Agent:..."
QT_MOC_LITERAL(39, 886, 16), // "DisconnectSignal"
QT_MOC_LITERAL(40, 903, 8), // "InitSlot"
QT_MOC_LITERAL(41, 912, 18), // "UpdateConfigsSlots"
QT_MOC_LITERAL(42, 931, 22), // "UploadMeasureDataSlots"
QT_MOC_LITERAL(43, 954, 23), // "UploadMeasureCurveSlots"
QT_MOC_LITERAL(44, 978, 25), // "UploadReagentProfileSlots"
QT_MOC_LITERAL(45, 1004, 24), // "UpdateReagentRemainSlots"
QT_MOC_LITERAL(46, 1029, 28), // "UploadConsumableProfileSlots"
QT_MOC_LITERAL(47, 1058, 23), // "UpdaterSignalTimerSlots"
QT_MOC_LITERAL(48, 1082, 25), // "SetSignalUpdateCycleSlots"
QT_MOC_LITERAL(49, 1108, 11), // "RebootSlots"
QT_MOC_LITERAL(50, 1120, 12), // "UpgradeSlots"
QT_MOC_LITERAL(51, 1133, 10), // "AlarmSlots"
QT_MOC_LITERAL(52, 1144, 17), // "UpdateStatusSlots"
QT_MOC_LITERAL(53, 1162, 17), // "UpdateActionSlots"
QT_MOC_LITERAL(54, 1180, 26), // "NotifyDiagnosisResultSlots"
QT_MOC_LITERAL(55, 1207, 19), // "UpgradeFinishedSlot"
QT_MOC_LITERAL(56, 1227, 16), // "UpgradeErrorSlot"
QT_MOC_LITERAL(57, 1244, 7), // "message"
QT_MOC_LITERAL(58, 1252, 20), // "UpgradeReadyReadSlot"
QT_MOC_LITERAL(59, 1273, 26), // "CalibrationTouchScreenSlot"
QT_MOC_LITERAL(60, 1300, 14), // "UpLoadFileSlot"
QT_MOC_LITERAL(61, 1315, 18), // "UpLoadFinishedSlot"
QT_MOC_LITERAL(62, 1334, 15), // "UpLoadErrorSlot"
QT_MOC_LITERAL(63, 1350, 16), // "DownloadFileSlot"
QT_MOC_LITERAL(64, 1367, 20), // "DownloadFinishedSlot"
QT_MOC_LITERAL(65, 1388, 17), // "DownloadErrorSlot"
QT_MOC_LITERAL(66, 1406, 21), // "DownloadReadyReadSlot"
QT_MOC_LITERAL(67, 1428, 23), // "ChangeHardwareParamSlot"
QT_MOC_LITERAL(68, 1452, 16), // "ConnectTimerSlot"
QT_MOC_LITERAL(69, 1469, 14) // "DisconnectSlot"

    },
    "Interface::Wqimc::WqimcManager\0"
    "InitSignal\0\0UpdateConfigsSignals\0"
    "std::vector<Interface::Wqimc::Api::Manager::Config>\0"
    "config\0UploadMeasureDataSignals\0"
    "Interface::Wqimc::Api::Manager::MeasureData\0"
    "data\0UploadMeasureCurveSignals\0"
    "Interface::Wqimc::Api::Manager::MeasureCurve\0"
    "curve\0UploadReagentProfileSignals\0"
    "UpdateReagentRemainSignals\0"
    "std::vector<Interface::Wqimc::Api::Manager::ReagentRemain>\0"
    "reagentRemainList\0UploadConsumableProfileSignals\0"
    "SetSignalUpdateCycleSignals\0cycleSec\0"
    "RebootSignals\0UpgradeSignals\0"
    "System::String\0url\0AlarmSignals\0"
    "Interface::Wqimc::Api::Manager::Alarm\0"
    "alarm\0UpdateStatusSignals\0"
    "Interface::Wqimc::Api::Manager::Status\0"
    "status\0UpdateActionSignals\0action\0"
    "NotifyDiagnosisResultSignals\0"
    "Interface::Wqimc::Api::Manager::DiagnosisResult\0"
    "result\0CalibrationTouchScreenSignals\0"
    "UpLoadFileSignal\0DownloadFileSignal\0"
    "ChangeHardwareParamSignals\0"
    "Interface::Wqimc::Api::Agent::Config\0"
    "DisconnectSignal\0InitSlot\0UpdateConfigsSlots\0"
    "UploadMeasureDataSlots\0UploadMeasureCurveSlots\0"
    "UploadReagentProfileSlots\0"
    "UpdateReagentRemainSlots\0"
    "UploadConsumableProfileSlots\0"
    "UpdaterSignalTimerSlots\0"
    "SetSignalUpdateCycleSlots\0RebootSlots\0"
    "UpgradeSlots\0AlarmSlots\0UpdateStatusSlots\0"
    "UpdateActionSlots\0NotifyDiagnosisResultSlots\0"
    "UpgradeFinishedSlot\0UpgradeErrorSlot\0"
    "message\0UpgradeReadyReadSlot\0"
    "CalibrationTouchScreenSlot\0UpLoadFileSlot\0"
    "UpLoadFinishedSlot\0UpLoadErrorSlot\0"
    "DownloadFileSlot\0DownloadFinishedSlot\0"
    "DownloadErrorSlot\0DownloadReadyReadSlot\0"
    "ChangeHardwareParamSlot\0ConnectTimerSlot\0"
    "DisconnectSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Interface__Wqimc__WqimcManager[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      48,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      19,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,  254,    2, 0x06 /* Public */,
       3,    1,  255,    2, 0x06 /* Public */,
       6,    1,  258,    2, 0x06 /* Public */,
       9,    1,  261,    2, 0x06 /* Public */,
      12,    0,  264,    2, 0x06 /* Public */,
      13,    1,  265,    2, 0x06 /* Public */,
      16,    0,  268,    2, 0x06 /* Public */,
      17,    1,  269,    2, 0x06 /* Public */,
      19,    0,  272,    2, 0x06 /* Public */,
      20,    1,  273,    2, 0x06 /* Public */,
      23,    1,  276,    2, 0x06 /* Public */,
      26,    1,  279,    2, 0x06 /* Public */,
      29,    1,  282,    2, 0x06 /* Public */,
      31,    1,  285,    2, 0x06 /* Public */,
      34,    0,  288,    2, 0x06 /* Public */,
      35,    0,  289,    2, 0x06 /* Public */,
      36,    0,  290,    2, 0x06 /* Public */,
      37,    1,  291,    2, 0x06 /* Public */,
      39,    0,  294,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      40,    0,  295,    2, 0x08 /* Private */,
      41,    1,  296,    2, 0x08 /* Private */,
      42,    1,  299,    2, 0x08 /* Private */,
      43,    1,  302,    2, 0x08 /* Private */,
      44,    0,  305,    2, 0x08 /* Private */,
      45,    1,  306,    2, 0x08 /* Private */,
      46,    0,  309,    2, 0x08 /* Private */,
      47,    0,  310,    2, 0x08 /* Private */,
      48,    1,  311,    2, 0x08 /* Private */,
      49,    0,  314,    2, 0x08 /* Private */,
      50,    1,  315,    2, 0x08 /* Private */,
      51,    1,  318,    2, 0x08 /* Private */,
      52,    1,  321,    2, 0x08 /* Private */,
      53,    1,  324,    2, 0x08 /* Private */,
      54,    1,  327,    2, 0x08 /* Private */,
      55,    0,  330,    2, 0x08 /* Private */,
      56,    1,  331,    2, 0x08 /* Private */,
      58,    1,  334,    2, 0x08 /* Private */,
      59,    0,  337,    2, 0x08 /* Private */,
      60,    0,  338,    2, 0x08 /* Private */,
      61,    0,  339,    2, 0x08 /* Private */,
      62,    1,  340,    2, 0x08 /* Private */,
      63,    0,  343,    2, 0x08 /* Private */,
      64,    0,  344,    2, 0x08 /* Private */,
      65,    1,  345,    2, 0x08 /* Private */,
      66,    1,  348,    2, 0x08 /* Private */,
      67,    1,  351,    2, 0x08 /* Private */,
      68,    0,  354,    2, 0x08 /* Private */,
      69,    0,  355,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 4,    5,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void, 0x80000000 | 10,   11,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 14,   15,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Double,   18,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 21,   22,
    QMetaType::Void, 0x80000000 | 24,   25,
    QMetaType::Void, 0x80000000 | 27,   28,
    QMetaType::Void, 0x80000000 | 27,   30,
    QMetaType::Void, 0x80000000 | 32,   33,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 38,    5,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 4,    5,
    QMetaType::Bool, 0x80000000 | 7,    8,
    QMetaType::Bool, 0x80000000 | 10,   11,
    QMetaType::Bool,
    QMetaType::Void, 0x80000000 | 14,   15,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Double,   18,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 21,   22,
    QMetaType::Void, 0x80000000 | 24,   25,
    QMetaType::Void, 0x80000000 | 27,   28,
    QMetaType::Void, 0x80000000 | 27,   30,
    QMetaType::Void, 0x80000000 | 32,   33,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   57,
    QMetaType::Void, QMetaType::QByteArray,    8,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   57,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   57,
    QMetaType::Void, QMetaType::QByteArray,    8,
    QMetaType::Void, 0x80000000 | 38,    5,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void Interface::Wqimc::WqimcManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        WqimcManager *_t = static_cast<WqimcManager *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->InitSignal(); break;
        case 1: _t->UpdateConfigsSignals((*reinterpret_cast< const std::vector<Interface::Wqimc::Api::Manager::Config>(*)>(_a[1]))); break;
        case 2: _t->UploadMeasureDataSignals((*reinterpret_cast< const Interface::Wqimc::Api::Manager::MeasureData(*)>(_a[1]))); break;
        case 3: _t->UploadMeasureCurveSignals((*reinterpret_cast< const Interface::Wqimc::Api::Manager::MeasureCurve(*)>(_a[1]))); break;
        case 4: _t->UploadReagentProfileSignals(); break;
        case 5: _t->UpdateReagentRemainSignals((*reinterpret_cast< const std::vector<Interface::Wqimc::Api::Manager::ReagentRemain>(*)>(_a[1]))); break;
        case 6: _t->UploadConsumableProfileSignals(); break;
        case 7: _t->SetSignalUpdateCycleSignals((*reinterpret_cast< const double(*)>(_a[1]))); break;
        case 8: _t->RebootSignals(); break;
        case 9: _t->UpgradeSignals((*reinterpret_cast< const System::String(*)>(_a[1]))); break;
        case 10: _t->AlarmSignals((*reinterpret_cast< const Interface::Wqimc::Api::Manager::Alarm(*)>(_a[1]))); break;
        case 11: _t->UpdateStatusSignals((*reinterpret_cast< const Interface::Wqimc::Api::Manager::Status(*)>(_a[1]))); break;
        case 12: _t->UpdateActionSignals((*reinterpret_cast< const Interface::Wqimc::Api::Manager::Status(*)>(_a[1]))); break;
        case 13: _t->NotifyDiagnosisResultSignals((*reinterpret_cast< const Interface::Wqimc::Api::Manager::DiagnosisResult(*)>(_a[1]))); break;
        case 14: _t->CalibrationTouchScreenSignals(); break;
        case 15: _t->UpLoadFileSignal(); break;
        case 16: _t->DownloadFileSignal(); break;
        case 17: _t->ChangeHardwareParamSignals((*reinterpret_cast< const Interface::Wqimc::Api::Agent::Config(*)>(_a[1]))); break;
        case 18: _t->DisconnectSignal(); break;
        case 19: _t->InitSlot(); break;
        case 20: _t->UpdateConfigsSlots((*reinterpret_cast< const std::vector<Interface::Wqimc::Api::Manager::Config>(*)>(_a[1]))); break;
        case 21: { bool _r = _t->UploadMeasureDataSlots((*reinterpret_cast< const Interface::Wqimc::Api::Manager::MeasureData(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 22: { bool _r = _t->UploadMeasureCurveSlots((*reinterpret_cast< const Interface::Wqimc::Api::Manager::MeasureCurve(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 23: { bool _r = _t->UploadReagentProfileSlots();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = _r; }  break;
        case 24: _t->UpdateReagentRemainSlots((*reinterpret_cast< const std::vector<Interface::Wqimc::Api::Manager::ReagentRemain>(*)>(_a[1]))); break;
        case 25: _t->UploadConsumableProfileSlots(); break;
        case 26: _t->UpdaterSignalTimerSlots(); break;
        case 27: _t->SetSignalUpdateCycleSlots((*reinterpret_cast< const double(*)>(_a[1]))); break;
        case 28: _t->RebootSlots(); break;
        case 29: _t->UpgradeSlots((*reinterpret_cast< const System::String(*)>(_a[1]))); break;
        case 30: _t->AlarmSlots((*reinterpret_cast< const Interface::Wqimc::Api::Manager::Alarm(*)>(_a[1]))); break;
        case 31: _t->UpdateStatusSlots((*reinterpret_cast< const Interface::Wqimc::Api::Manager::Status(*)>(_a[1]))); break;
        case 32: _t->UpdateActionSlots((*reinterpret_cast< const Interface::Wqimc::Api::Manager::Status(*)>(_a[1]))); break;
        case 33: _t->NotifyDiagnosisResultSlots((*reinterpret_cast< const Interface::Wqimc::Api::Manager::DiagnosisResult(*)>(_a[1]))); break;
        case 34: _t->UpgradeFinishedSlot(); break;
        case 35: _t->UpgradeErrorSlot((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 36: _t->UpgradeReadyReadSlot((*reinterpret_cast< const QByteArray(*)>(_a[1]))); break;
        case 37: _t->CalibrationTouchScreenSlot(); break;
        case 38: _t->UpLoadFileSlot(); break;
        case 39: _t->UpLoadFinishedSlot(); break;
        case 40: _t->UpLoadErrorSlot((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 41: _t->DownloadFileSlot(); break;
        case 42: _t->DownloadFinishedSlot(); break;
        case 43: _t->DownloadErrorSlot((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 44: _t->DownloadReadyReadSlot((*reinterpret_cast< const QByteArray(*)>(_a[1]))); break;
        case 45: _t->ChangeHardwareParamSlot((*reinterpret_cast< const Interface::Wqimc::Api::Agent::Config(*)>(_a[1]))); break;
        case 46: _t->ConnectTimerSlot(); break;
        case 47: _t->DisconnectSlot(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 1:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< std::vector<Interface::Wqimc::Api::Manager::Config> >(); break;
            }
            break;
        case 2:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::MeasureData >(); break;
            }
            break;
        case 3:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::MeasureCurve >(); break;
            }
            break;
        case 5:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< std::vector<Interface::Wqimc::Api::Manager::ReagentRemain> >(); break;
            }
            break;
        case 10:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::Alarm >(); break;
            }
            break;
        case 11:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::Status >(); break;
            }
            break;
        case 12:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::Status >(); break;
            }
            break;
        case 13:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::DiagnosisResult >(); break;
            }
            break;
        case 17:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Agent::Config >(); break;
            }
            break;
        case 20:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< std::vector<Interface::Wqimc::Api::Manager::Config> >(); break;
            }
            break;
        case 21:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::MeasureData >(); break;
            }
            break;
        case 22:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::MeasureCurve >(); break;
            }
            break;
        case 24:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< std::vector<Interface::Wqimc::Api::Manager::ReagentRemain> >(); break;
            }
            break;
        case 30:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::Alarm >(); break;
            }
            break;
        case 31:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::Status >(); break;
            }
            break;
        case 32:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::Status >(); break;
            }
            break;
        case 33:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Manager::DiagnosisResult >(); break;
            }
            break;
        case 45:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< Interface::Wqimc::Api::Agent::Config >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::InitSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const std::vector<Interface::Wqimc::Api::Manager::Config> & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UpdateConfigsSignals)) {
                *result = 1;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const Interface::Wqimc::Api::Manager::MeasureData & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UploadMeasureDataSignals)) {
                *result = 2;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const Interface::Wqimc::Api::Manager::MeasureCurve & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UploadMeasureCurveSignals)) {
                *result = 3;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UploadReagentProfileSignals)) {
                *result = 4;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const std::vector<Interface::Wqimc::Api::Manager::ReagentRemain> & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UpdateReagentRemainSignals)) {
                *result = 5;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UploadConsumableProfileSignals)) {
                *result = 6;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const double );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::SetSignalUpdateCycleSignals)) {
                *result = 7;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::RebootSignals)) {
                *result = 8;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const System::String & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UpgradeSignals)) {
                *result = 9;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const Interface::Wqimc::Api::Manager::Alarm & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::AlarmSignals)) {
                *result = 10;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const Interface::Wqimc::Api::Manager::Status & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UpdateStatusSignals)) {
                *result = 11;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const Interface::Wqimc::Api::Manager::Status & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UpdateActionSignals)) {
                *result = 12;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const Interface::Wqimc::Api::Manager::DiagnosisResult & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::NotifyDiagnosisResultSignals)) {
                *result = 13;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::CalibrationTouchScreenSignals)) {
                *result = 14;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::UpLoadFileSignal)) {
                *result = 15;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::DownloadFileSignal)) {
                *result = 16;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)(const Interface::Wqimc::Api::Agent::Config );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::ChangeHardwareParamSignals)) {
                *result = 17;
                return;
            }
        }
        {
            typedef void (WqimcManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WqimcManager::DisconnectSignal)) {
                *result = 18;
                return;
            }
        }
    }
}

const QMetaObject Interface::Wqimc::WqimcManager::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Interface__Wqimc__WqimcManager.data,
      qt_meta_data_Interface__Wqimc__WqimcManager,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Interface::Wqimc::WqimcManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Interface::Wqimc::WqimcManager::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Interface__Wqimc__WqimcManager.stringdata0))
        return static_cast<void*>(const_cast< WqimcManager*>(this));
    if (!strcmp(_clname, "Measure::IStatusNotifiable"))
        return static_cast< Measure::IStatusNotifiable*>(const_cast< WqimcManager*>(this));
    if (!strcmp(_clname, "erchashu::thrift::ConnectionNotifier"))
        return static_cast< erchashu::thrift::ConnectionNotifier*>(const_cast< WqimcManager*>(this));
    return QObject::qt_metacast(_clname);
}

int Interface::Wqimc::WqimcManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 48)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 48;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 48)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 48;
    }
    return _id;
}

// SIGNAL 0
void Interface::Wqimc::WqimcManager::InitSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void Interface::Wqimc::WqimcManager::UpdateConfigsSignals(const std::vector<Interface::Wqimc::Api::Manager::Config> & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void Interface::Wqimc::WqimcManager::UploadMeasureDataSignals(const Interface::Wqimc::Api::Manager::MeasureData & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void Interface::Wqimc::WqimcManager::UploadMeasureCurveSignals(const Interface::Wqimc::Api::Manager::MeasureCurve & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void Interface::Wqimc::WqimcManager::UploadReagentProfileSignals()
{
    QMetaObject::activate(this, &staticMetaObject, 4, Q_NULLPTR);
}

// SIGNAL 5
void Interface::Wqimc::WqimcManager::UpdateReagentRemainSignals(const std::vector<Interface::Wqimc::Api::Manager::ReagentRemain> & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void Interface::Wqimc::WqimcManager::UploadConsumableProfileSignals()
{
    QMetaObject::activate(this, &staticMetaObject, 6, Q_NULLPTR);
}

// SIGNAL 7
void Interface::Wqimc::WqimcManager::SetSignalUpdateCycleSignals(const double _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 7, _a);
}

// SIGNAL 8
void Interface::Wqimc::WqimcManager::RebootSignals()
{
    QMetaObject::activate(this, &staticMetaObject, 8, Q_NULLPTR);
}

// SIGNAL 9
void Interface::Wqimc::WqimcManager::UpgradeSignals(const System::String & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 9, _a);
}

// SIGNAL 10
void Interface::Wqimc::WqimcManager::AlarmSignals(const Interface::Wqimc::Api::Manager::Alarm & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 10, _a);
}

// SIGNAL 11
void Interface::Wqimc::WqimcManager::UpdateStatusSignals(const Interface::Wqimc::Api::Manager::Status & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 11, _a);
}

// SIGNAL 12
void Interface::Wqimc::WqimcManager::UpdateActionSignals(const Interface::Wqimc::Api::Manager::Status & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 12, _a);
}

// SIGNAL 13
void Interface::Wqimc::WqimcManager::NotifyDiagnosisResultSignals(const Interface::Wqimc::Api::Manager::DiagnosisResult & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 13, _a);
}

// SIGNAL 14
void Interface::Wqimc::WqimcManager::CalibrationTouchScreenSignals()
{
    QMetaObject::activate(this, &staticMetaObject, 14, Q_NULLPTR);
}

// SIGNAL 15
void Interface::Wqimc::WqimcManager::UpLoadFileSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 15, Q_NULLPTR);
}

// SIGNAL 16
void Interface::Wqimc::WqimcManager::DownloadFileSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 16, Q_NULLPTR);
}

// SIGNAL 17
void Interface::Wqimc::WqimcManager::ChangeHardwareParamSignals(const Interface::Wqimc::Api::Agent::Config _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 17, _a);
}

// SIGNAL 18
void Interface::Wqimc::WqimcManager::DisconnectSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 18, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
