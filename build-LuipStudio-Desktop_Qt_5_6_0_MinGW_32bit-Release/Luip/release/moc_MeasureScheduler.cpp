/****************************************************************************
** Meta object code from reading C++ file 'MeasureScheduler.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/FlowManager/MeasureScheduler.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'MeasureScheduler.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Flow__MeasureScheduler_t {
    QByteArrayData data[26];
    char stringdata0[378];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Flow__MeasureScheduler_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Flow__MeasureScheduler_t qt_meta_stringdata_Flow__MeasureScheduler = {
    {
QT_MOC_LITERAL(0, 0, 22), // "Flow::MeasureScheduler"
QT_MOC_LITERAL(1, 23, 10), // "InitSignal"
QT_MOC_LITERAL(2, 34, 0), // ""
QT_MOC_LITERAL(3, 35, 12), // "UpdateSignal"
QT_MOC_LITERAL(4, 48, 18), // "EnabledTimerSignal"
QT_MOC_LITERAL(5, 67, 6), // "status"
QT_MOC_LITERAL(6, 74, 21), // "OnFlowActivatedSignal"
QT_MOC_LITERAL(7, 96, 4), // "name"
QT_MOC_LITERAL(8, 101, 4), // "time"
QT_MOC_LITERAL(9, 106, 20), // "OnFlowFinishedSignal"
QT_MOC_LITERAL(10, 127, 6), // "result"
QT_MOC_LITERAL(11, 134, 22), // "OnFlowThreadExitSignal"
QT_MOC_LITERAL(12, 157, 16), // "StartTimerSignal"
QT_MOC_LITERAL(13, 174, 5), // "times"
QT_MOC_LITERAL(14, 180, 15), // "StopTimerSignal"
QT_MOC_LITERAL(15, 196, 8), // "InitSlot"
QT_MOC_LITERAL(16, 205, 10), // "UpdateSlot"
QT_MOC_LITERAL(17, 216, 16), // "EnabledTimerSlot"
QT_MOC_LITERAL(18, 233, 11), // "TimeoutSlot"
QT_MOC_LITERAL(19, 245, 25), // "CheckSchedulerTimeoutSlot"
QT_MOC_LITERAL(20, 271, 19), // "OnFlowActivatedSlot"
QT_MOC_LITERAL(21, 291, 18), // "OnFlowFinishedSlot"
QT_MOC_LITERAL(22, 310, 20), // "OnFlowThreadExitSlot"
QT_MOC_LITERAL(23, 331, 14), // "StartTimerSlot"
QT_MOC_LITERAL(24, 346, 13), // "StopTimerSlot"
QT_MOC_LITERAL(25, 360, 17) // "SlotCalibrateTime"

    },
    "Flow::MeasureScheduler\0InitSignal\0\0"
    "UpdateSignal\0EnabledTimerSignal\0status\0"
    "OnFlowActivatedSignal\0name\0time\0"
    "OnFlowFinishedSignal\0result\0"
    "OnFlowThreadExitSignal\0StartTimerSignal\0"
    "times\0StopTimerSignal\0InitSlot\0"
    "UpdateSlot\0EnabledTimerSlot\0TimeoutSlot\0"
    "CheckSchedulerTimeoutSlot\0OnFlowActivatedSlot\0"
    "OnFlowFinishedSlot\0OnFlowThreadExitSlot\0"
    "StartTimerSlot\0StopTimerSlot\0"
    "SlotCalibrateTime"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Flow__MeasureScheduler[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      19,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       8,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,  109,    2, 0x06 /* Public */,
       3,    0,  110,    2, 0x06 /* Public */,
       4,    1,  111,    2, 0x06 /* Public */,
       6,    2,  114,    2, 0x06 /* Public */,
       9,    2,  119,    2, 0x06 /* Public */,
      11,    0,  124,    2, 0x06 /* Public */,
      12,    1,  125,    2, 0x06 /* Public */,
      14,    0,  128,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      15,    0,  129,    2, 0x0a /* Public */,
      16,    0,  130,    2, 0x0a /* Public */,
      17,    1,  131,    2, 0x0a /* Public */,
      18,    0,  134,    2, 0x0a /* Public */,
      19,    0,  135,    2, 0x0a /* Public */,
      20,    2,  136,    2, 0x0a /* Public */,
      21,    2,  141,    2, 0x0a /* Public */,
      22,    0,  146,    2, 0x0a /* Public */,
      23,    1,  147,    2, 0x0a /* Public */,
      24,    0,  150,    2, 0x0a /* Public */,
      25,    0,  151,    2, 0x0a /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Bool,    5,
    QMetaType::Void, QMetaType::QString, QMetaType::Long,    7,    8,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    7,   10,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,   13,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Bool,    5,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString, QMetaType::Long,    7,    8,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    7,   10,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,   13,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void Flow::MeasureScheduler::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        MeasureScheduler *_t = static_cast<MeasureScheduler *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->InitSignal(); break;
        case 1: _t->UpdateSignal(); break;
        case 2: _t->EnabledTimerSignal((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 3: _t->OnFlowActivatedSignal((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< long(*)>(_a[2]))); break;
        case 4: _t->OnFlowFinishedSignal((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 5: _t->OnFlowThreadExitSignal(); break;
        case 6: _t->StartTimerSignal((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 7: _t->StopTimerSignal(); break;
        case 8: _t->InitSlot(); break;
        case 9: _t->UpdateSlot(); break;
        case 10: _t->EnabledTimerSlot((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 11: _t->TimeoutSlot(); break;
        case 12: _t->CheckSchedulerTimeoutSlot(); break;
        case 13: _t->OnFlowActivatedSlot((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< long(*)>(_a[2]))); break;
        case 14: _t->OnFlowFinishedSlot((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 15: _t->OnFlowThreadExitSlot(); break;
        case 16: _t->StartTimerSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 17: _t->StopTimerSlot(); break;
        case 18: _t->SlotCalibrateTime(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (MeasureScheduler::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::InitSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (MeasureScheduler::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::UpdateSignal)) {
                *result = 1;
                return;
            }
        }
        {
            typedef void (MeasureScheduler::*_t)(bool );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::EnabledTimerSignal)) {
                *result = 2;
                return;
            }
        }
        {
            typedef void (MeasureScheduler::*_t)(QString , long );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::OnFlowActivatedSignal)) {
                *result = 3;
                return;
            }
        }
        {
            typedef void (MeasureScheduler::*_t)(QString , QString );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::OnFlowFinishedSignal)) {
                *result = 4;
                return;
            }
        }
        {
            typedef void (MeasureScheduler::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::OnFlowThreadExitSignal)) {
                *result = 5;
                return;
            }
        }
        {
            typedef void (MeasureScheduler::*_t)(int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::StartTimerSignal)) {
                *result = 6;
                return;
            }
        }
        {
            typedef void (MeasureScheduler::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureScheduler::StopTimerSignal)) {
                *result = 7;
                return;
            }
        }
    }
}

const QMetaObject Flow::MeasureScheduler::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Flow__MeasureScheduler.data,
      qt_meta_data_Flow__MeasureScheduler,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Flow::MeasureScheduler::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Flow::MeasureScheduler::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Flow__MeasureScheduler.stringdata0))
        return static_cast<void*>(const_cast< MeasureScheduler*>(this));
    if (!strcmp(_clname, "IFlowNotifiable"))
        return static_cast< IFlowNotifiable*>(const_cast< MeasureScheduler*>(this));
    return QObject::qt_metacast(_clname);
}

int Flow::MeasureScheduler::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 19)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 19;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 19)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 19;
    }
    return _id;
}

// SIGNAL 0
void Flow::MeasureScheduler::InitSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void Flow::MeasureScheduler::UpdateSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 1, Q_NULLPTR);
}

// SIGNAL 2
void Flow::MeasureScheduler::EnabledTimerSignal(bool _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void Flow::MeasureScheduler::OnFlowActivatedSignal(QString _t1, long _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void Flow::MeasureScheduler::OnFlowFinishedSignal(QString _t1, QString _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void Flow::MeasureScheduler::OnFlowThreadExitSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 5, Q_NULLPTR);
}

// SIGNAL 6
void Flow::MeasureScheduler::StartTimerSignal(int _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void Flow::MeasureScheduler::StopTimerSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 7, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
