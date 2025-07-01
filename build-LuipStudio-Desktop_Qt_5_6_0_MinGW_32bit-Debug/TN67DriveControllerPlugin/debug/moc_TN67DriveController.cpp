/****************************************************************************
** Meta object code from reading C++ file 'TN67DriveController.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/TN67DriveControllerPlugin/TN67DriveController.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'TN67DriveController.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Controller__TN67DriveController_t {
    QByteArrayData data[5];
    char stringdata0[76];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Controller__TN67DriveController_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Controller__TN67DriveController_t qt_meta_stringdata_Controller__TN67DriveController = {
    {
QT_MOC_LITERAL(0, 0, 31), // "Controller::TN67DriveController"
QT_MOC_LITERAL(1, 32, 19), // "BoxFanControlSignal"
QT_MOC_LITERAL(2, 52, 0), // ""
QT_MOC_LITERAL(3, 53, 4), // "temp"
QT_MOC_LITERAL(4, 58, 17) // "BoxFanControlSlot"

    },
    "Controller::TN67DriveController\0"
    "BoxFanControlSignal\0\0temp\0BoxFanControlSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Controller__TN67DriveController[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   24,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       4,    1,   27,    2, 0x0a /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::Float,    3,

 // slots: parameters
    QMetaType::Void, QMetaType::Float,    3,

       0        // eod
};

void Controller::TN67DriveController::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        TN67DriveController *_t = static_cast<TN67DriveController *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->BoxFanControlSignal((*reinterpret_cast< float(*)>(_a[1]))); break;
        case 1: _t->BoxFanControlSlot((*reinterpret_cast< float(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (TN67DriveController::*_t)(float );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TN67DriveController::BoxFanControlSignal)) {
                *result = 0;
                return;
            }
        }
    }
}

const QMetaObject Controller::TN67DriveController::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Controller__TN67DriveController.data,
      qt_meta_data_Controller__TN67DriveController,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Controller::TN67DriveController::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Controller::TN67DriveController::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Controller__TN67DriveController.stringdata0))
        return static_cast<void*>(const_cast< TN67DriveController*>(this));
    if (!strcmp(_clname, "BaseController"))
        return static_cast< BaseController*>(const_cast< TN67DriveController*>(this));
    return QObject::qt_metacast(_clname);
}

int Controller::TN67DriveController::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 2)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 2)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 2;
    }
    return _id;
}

// SIGNAL 0
void Controller::TN67DriveController::BoxFanControlSignal(float _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
