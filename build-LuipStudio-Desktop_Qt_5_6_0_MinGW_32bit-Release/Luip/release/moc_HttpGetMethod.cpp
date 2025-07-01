/****************************************************************************
** Meta object code from reading C++ file 'HttpGetMethod.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/Interface/Wqimc/HttpGetMethod.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'HttpGetMethod.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Interface__Wqimc__HttpGetMethod_t {
    QByteArrayData data[12];
    char stringdata0[161];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Interface__Wqimc__HttpGetMethod_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Interface__Wqimc__HttpGetMethod_t qt_meta_stringdata_Interface__Wqimc__HttpGetMethod = {
    {
QT_MOC_LITERAL(0, 0, 31), // "Interface::Wqimc::HttpGetMethod"
QT_MOC_LITERAL(1, 32, 14), // "FinishedSignal"
QT_MOC_LITERAL(2, 47, 0), // ""
QT_MOC_LITERAL(3, 48, 11), // "ErrorSignal"
QT_MOC_LITERAL(4, 60, 7), // "message"
QT_MOC_LITERAL(5, 68, 15), // "ReadyReadSignal"
QT_MOC_LITERAL(6, 84, 4), // "data"
QT_MOC_LITERAL(7, 89, 13), // "ReadyReadSlot"
QT_MOC_LITERAL(8, 103, 20), // "DownloadProgressSlot"
QT_MOC_LITERAL(9, 124, 13), // "bytesReceived"
QT_MOC_LITERAL(10, 138, 10), // "bytesTotal"
QT_MOC_LITERAL(11, 149, 11) // "TimeoutSlot"

    },
    "Interface::Wqimc::HttpGetMethod\0"
    "FinishedSignal\0\0ErrorSignal\0message\0"
    "ReadyReadSignal\0data\0ReadyReadSlot\0"
    "DownloadProgressSlot\0bytesReceived\0"
    "bytesTotal\0TimeoutSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Interface__Wqimc__HttpGetMethod[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       3,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   44,    2, 0x06 /* Public */,
       3,    1,   45,    2, 0x06 /* Public */,
       5,    1,   48,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       7,    0,   51,    2, 0x0a /* Public */,
       8,    2,   52,    2, 0x0a /* Public */,
      11,    0,   57,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,
    QMetaType::Void, QMetaType::QByteArray,    6,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::LongLong, QMetaType::LongLong,    9,   10,
    QMetaType::Void,

       0        // eod
};

void Interface::Wqimc::HttpGetMethod::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        HttpGetMethod *_t = static_cast<HttpGetMethod *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->FinishedSignal(); break;
        case 1: _t->ErrorSignal((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 2: _t->ReadyReadSignal((*reinterpret_cast< const QByteArray(*)>(_a[1]))); break;
        case 3: _t->ReadyReadSlot(); break;
        case 4: _t->DownloadProgressSlot((*reinterpret_cast< qint64(*)>(_a[1])),(*reinterpret_cast< qint64(*)>(_a[2]))); break;
        case 5: _t->TimeoutSlot(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (HttpGetMethod::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HttpGetMethod::FinishedSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (HttpGetMethod::*_t)(const QString );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HttpGetMethod::ErrorSignal)) {
                *result = 1;
                return;
            }
        }
        {
            typedef void (HttpGetMethod::*_t)(const QByteArray & );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HttpGetMethod::ReadyReadSignal)) {
                *result = 2;
                return;
            }
        }
    }
}

const QMetaObject Interface::Wqimc::HttpGetMethod::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Interface__Wqimc__HttpGetMethod.data,
      qt_meta_data_Interface__Wqimc__HttpGetMethod,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Interface::Wqimc::HttpGetMethod::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Interface::Wqimc::HttpGetMethod::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Interface__Wqimc__HttpGetMethod.stringdata0))
        return static_cast<void*>(const_cast< HttpGetMethod*>(this));
    return QObject::qt_metacast(_clname);
}

int Interface::Wqimc::HttpGetMethod::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
void Interface::Wqimc::HttpGetMethod::FinishedSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void Interface::Wqimc::HttpGetMethod::ErrorSignal(const QString _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void Interface::Wqimc::HttpGetMethod::ReadyReadSignal(const QByteArray & _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}
QT_END_MOC_NAMESPACE
