/****************************************************************************
** Meta object code from reading C++ file 'HttpClient.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/Interface/Wqimc/HttpClient.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'HttpClient.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Interface__Wqimc__HttpClient_t {
    QByteArrayData data[14];
    char stringdata0[225];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Interface__Wqimc__HttpClient_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Interface__Wqimc__HttpClient_t qt_meta_stringdata_Interface__Wqimc__HttpClient = {
    {
QT_MOC_LITERAL(0, 0, 28), // "Interface::Wqimc::HttpClient"
QT_MOC_LITERAL(1, 29, 24), // "PostMethodFinishedSignal"
QT_MOC_LITERAL(2, 54, 0), // ""
QT_MOC_LITERAL(3, 55, 21), // "PostMethodErrorSignal"
QT_MOC_LITERAL(4, 77, 7), // "message"
QT_MOC_LITERAL(5, 85, 26), // "AuthenticationRequiredSlot"
QT_MOC_LITERAL(6, 112, 14), // "QNetworkReply*"
QT_MOC_LITERAL(7, 127, 15), // "QAuthenticator*"
QT_MOC_LITERAL(8, 143, 13), // "ReplyFinished"
QT_MOC_LITERAL(9, 157, 5), // "reply"
QT_MOC_LITERAL(10, 163, 18), // "UploadProgressSlot"
QT_MOC_LITERAL(11, 182, 9), // "bytesSent"
QT_MOC_LITERAL(12, 192, 10), // "bytesTotal"
QT_MOC_LITERAL(13, 203, 21) // "PostMethodTimeoutSlot"

    },
    "Interface::Wqimc::HttpClient\0"
    "PostMethodFinishedSignal\0\0"
    "PostMethodErrorSignal\0message\0"
    "AuthenticationRequiredSlot\0QNetworkReply*\0"
    "QAuthenticator*\0ReplyFinished\0reply\0"
    "UploadProgressSlot\0bytesSent\0bytesTotal\0"
    "PostMethodTimeoutSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Interface__Wqimc__HttpClient[] = {

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
       1,    0,   44,    2, 0x06 /* Public */,
       3,    1,   45,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       5,    2,   48,    2, 0x08 /* Private */,
       8,    1,   53,    2, 0x08 /* Private */,
      10,    2,   56,    2, 0x08 /* Private */,
      13,    0,   61,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 6, 0x80000000 | 7,    2,    2,
    QMetaType::Void, 0x80000000 | 6,    9,
    QMetaType::Void, QMetaType::LongLong, QMetaType::LongLong,   11,   12,
    QMetaType::Void,

       0        // eod
};

void Interface::Wqimc::HttpClient::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        HttpClient *_t = static_cast<HttpClient *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->PostMethodFinishedSignal(); break;
        case 1: _t->PostMethodErrorSignal((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 2: _t->AuthenticationRequiredSlot((*reinterpret_cast< QNetworkReply*(*)>(_a[1])),(*reinterpret_cast< QAuthenticator*(*)>(_a[2]))); break;
        case 3: _t->ReplyFinished((*reinterpret_cast< QNetworkReply*(*)>(_a[1]))); break;
        case 4: _t->UploadProgressSlot((*reinterpret_cast< qint64(*)>(_a[1])),(*reinterpret_cast< qint64(*)>(_a[2]))); break;
        case 5: _t->PostMethodTimeoutSlot(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 2:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QNetworkReply* >(); break;
            }
            break;
        case 3:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QNetworkReply* >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (HttpClient::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HttpClient::PostMethodFinishedSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (HttpClient::*_t)(const QString );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HttpClient::PostMethodErrorSignal)) {
                *result = 1;
                return;
            }
        }
    }
}

const QMetaObject Interface::Wqimc::HttpClient::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Interface__Wqimc__HttpClient.data,
      qt_meta_data_Interface__Wqimc__HttpClient,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Interface::Wqimc::HttpClient::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Interface::Wqimc::HttpClient::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Interface__Wqimc__HttpClient.stringdata0))
        return static_cast<void*>(const_cast< HttpClient*>(this));
    return QObject::qt_metacast(_clname);
}

int Interface::Wqimc::HttpClient::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void Interface::Wqimc::HttpClient::PostMethodFinishedSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void Interface::Wqimc::HttpClient::PostMethodErrorSignal(const QString _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
