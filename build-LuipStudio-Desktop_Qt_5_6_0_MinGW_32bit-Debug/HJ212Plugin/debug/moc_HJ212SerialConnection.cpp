/****************************************************************************
** Meta object code from reading C++ file 'HJ212SerialConnection.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/HJ212Plugin/HJ212SerialConnection.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'HJ212SerialConnection.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_HJ212__HJ212SerialConnection_t {
    QByteArrayData data[12];
    char stringdata0[165];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_HJ212__HJ212SerialConnection_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_HJ212__HJ212SerialConnection_t qt_meta_stringdata_HJ212__HJ212SerialConnection = {
    {
QT_MOC_LITERAL(0, 0, 28), // "HJ212::HJ212SerialConnection"
QT_MOC_LITERAL(1, 29, 14), // "SignalSendData"
QT_MOC_LITERAL(2, 44, 0), // ""
QT_MOC_LITERAL(3, 45, 11), // "std::string"
QT_MOC_LITERAL(4, 57, 6), // "buffer"
QT_MOC_LITERAL(5, 64, 3), // "len"
QT_MOC_LITERAL(6, 68, 22), // "SignalSendDataBlocking"
QT_MOC_LITERAL(7, 91, 12), // "SignalReOpen"
QT_MOC_LITERAL(8, 104, 20), // "SignalReOpenBlocking"
QT_MOC_LITERAL(9, 125, 15), // "SlotReceiveData"
QT_MOC_LITERAL(10, 141, 12), // "SlotSendData"
QT_MOC_LITERAL(11, 154, 10) // "SlotReOpen"

    },
    "HJ212::HJ212SerialConnection\0"
    "SignalSendData\0\0std::string\0buffer\0"
    "len\0SignalSendDataBlocking\0SignalReOpen\0"
    "SignalReOpenBlocking\0SlotReceiveData\0"
    "SlotSendData\0SlotReOpen"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_HJ212__HJ212SerialConnection[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       7,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       4,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    2,   49,    2, 0x06 /* Public */,
       6,    2,   54,    2, 0x06 /* Public */,
       7,    0,   59,    2, 0x06 /* Public */,
       8,    0,   60,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       9,    0,   61,    2, 0x08 /* Private */,
      10,    2,   62,    2, 0x08 /* Private */,
      11,    0,   67,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3, QMetaType::Int,    4,    5,
    QMetaType::Void, 0x80000000 | 3, QMetaType::Int,    4,    5,
    QMetaType::Void,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 3, QMetaType::Int,    4,    5,
    QMetaType::Void,

       0        // eod
};

void HJ212::HJ212SerialConnection::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        HJ212SerialConnection *_t = static_cast<HJ212SerialConnection *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SignalSendData((*reinterpret_cast< std::string(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2]))); break;
        case 1: _t->SignalSendDataBlocking((*reinterpret_cast< std::string(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2]))); break;
        case 2: _t->SignalReOpen(); break;
        case 3: _t->SignalReOpenBlocking(); break;
        case 4: _t->SlotReceiveData(); break;
        case 5: _t->SlotSendData((*reinterpret_cast< std::string(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2]))); break;
        case 6: _t->SlotReOpen(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (HJ212SerialConnection::*_t)(std::string , int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HJ212SerialConnection::SignalSendData)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (HJ212SerialConnection::*_t)(std::string , int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HJ212SerialConnection::SignalSendDataBlocking)) {
                *result = 1;
                return;
            }
        }
        {
            typedef void (HJ212SerialConnection::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HJ212SerialConnection::SignalReOpen)) {
                *result = 2;
                return;
            }
        }
        {
            typedef void (HJ212SerialConnection::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HJ212SerialConnection::SignalReOpenBlocking)) {
                *result = 3;
                return;
            }
        }
    }
}

const QMetaObject HJ212::HJ212SerialConnection::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_HJ212__HJ212SerialConnection.data,
      qt_meta_data_HJ212__HJ212SerialConnection,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *HJ212::HJ212SerialConnection::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *HJ212::HJ212SerialConnection::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_HJ212__HJ212SerialConnection.stringdata0))
        return static_cast<void*>(const_cast< HJ212SerialConnection*>(this));
    if (!strcmp(_clname, "HJ212Connection"))
        return static_cast< HJ212Connection*>(const_cast< HJ212SerialConnection*>(this));
    return QObject::qt_metacast(_clname);
}

int HJ212::HJ212SerialConnection::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 7)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 7;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 7)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 7;
    }
    return _id;
}

// SIGNAL 0
void HJ212::HJ212SerialConnection::SignalSendData(std::string _t1, int _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void HJ212::HJ212SerialConnection::SignalSendDataBlocking(std::string _t1, int _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void HJ212::HJ212SerialConnection::SignalReOpen()
{
    QMetaObject::activate(this, &staticMetaObject, 2, Q_NULLPTR);
}

// SIGNAL 3
void HJ212::HJ212SerialConnection::SignalReOpenBlocking()
{
    QMetaObject::activate(this, &staticMetaObject, 3, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
