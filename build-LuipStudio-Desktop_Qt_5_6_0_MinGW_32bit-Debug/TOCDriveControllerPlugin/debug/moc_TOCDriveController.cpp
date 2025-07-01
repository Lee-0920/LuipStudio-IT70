/****************************************************************************
** Meta object code from reading C++ file 'TOCDriveController.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/TOCDriveControllerPlugin/TOCDriveController.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'TOCDriveController.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Controller__TOCDriveController_t {
    QByteArrayData data[9];
    char stringdata0[161];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Controller__TOCDriveController_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Controller__TOCDriveController_t qt_meta_stringdata_Controller__TOCDriveController = {
    {
QT_MOC_LITERAL(0, 0, 30), // "Controller::TOCDriveController"
QT_MOC_LITERAL(1, 31, 19), // "BoxFanControlSignal"
QT_MOC_LITERAL(2, 51, 0), // ""
QT_MOC_LITERAL(3, 52, 4), // "temp"
QT_MOC_LITERAL(4, 57, 21), // "ExBoxFanControlSignal"
QT_MOC_LITERAL(5, 79, 17), // "BoxFanControlSlot"
QT_MOC_LITERAL(6, 97, 19), // "ExBoxFanControlSlot"
QT_MOC_LITERAL(7, 117, 21), // "ThermostatMonitorSlot"
QT_MOC_LITERAL(8, 139, 21) // "BaseLineStatusMonitor"

    },
    "Controller::TOCDriveController\0"
    "BoxFanControlSignal\0\0temp\0"
    "ExBoxFanControlSignal\0BoxFanControlSlot\0"
    "ExBoxFanControlSlot\0ThermostatMonitorSlot\0"
    "BaseLineStatusMonitor"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Controller__TOCDriveController[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   44,    2, 0x06 /* Public */,
       4,    1,   47,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       5,    1,   50,    2, 0x0a /* Public */,
       6,    1,   53,    2, 0x0a /* Public */,
       7,    0,   56,    2, 0x0a /* Public */,
       8,    0,   57,    2, 0x0a /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::Float,    3,
    QMetaType::Void, QMetaType::Float,    3,

 // slots: parameters
    QMetaType::Void, QMetaType::Float,    3,
    QMetaType::Void, QMetaType::Float,    3,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void Controller::TOCDriveController::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        TOCDriveController *_t = static_cast<TOCDriveController *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->BoxFanControlSignal((*reinterpret_cast< float(*)>(_a[1]))); break;
        case 1: _t->ExBoxFanControlSignal((*reinterpret_cast< float(*)>(_a[1]))); break;
        case 2: _t->BoxFanControlSlot((*reinterpret_cast< float(*)>(_a[1]))); break;
        case 3: _t->ExBoxFanControlSlot((*reinterpret_cast< float(*)>(_a[1]))); break;
        case 4: _t->ThermostatMonitorSlot(); break;
        case 5: _t->BaseLineStatusMonitor(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (TOCDriveController::*_t)(float );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TOCDriveController::BoxFanControlSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (TOCDriveController::*_t)(float );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TOCDriveController::ExBoxFanControlSignal)) {
                *result = 1;
                return;
            }
        }
    }
}

const QMetaObject Controller::TOCDriveController::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Controller__TOCDriveController.data,
      qt_meta_data_Controller__TOCDriveController,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Controller::TOCDriveController::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Controller::TOCDriveController::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Controller__TOCDriveController.stringdata0))
        return static_cast<void*>(const_cast< TOCDriveController*>(this));
    if (!strcmp(_clname, "BaseController"))
        return static_cast< BaseController*>(const_cast< TOCDriveController*>(this));
    return QObject::qt_metacast(_clname);
}

int Controller::TOCDriveController::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 6)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void Controller::TOCDriveController::BoxFanControlSignal(float _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void Controller::TOCDriveController::ExBoxFanControlSignal(float _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
