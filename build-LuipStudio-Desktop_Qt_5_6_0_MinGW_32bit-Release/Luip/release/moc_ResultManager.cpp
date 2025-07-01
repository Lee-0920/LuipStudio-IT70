/****************************************************************************
** Meta object code from reading C++ file 'ResultManager.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/ResultManager/ResultManager.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ResultManager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_Result__ResultManager_t {
    QByteArrayData data[12];
    char stringdata0[189];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_Result__ResultManager_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_Result__ResultManager_t qt_meta_stringdata_Result__ResultManager = {
    {
QT_MOC_LITERAL(0, 0, 21), // "Result::ResultManager"
QT_MOC_LITERAL(1, 22, 23), // "AddMeasureRecordSignals"
QT_MOC_LITERAL(2, 46, 0), // ""
QT_MOC_LITERAL(3, 47, 14), // "System::String"
QT_MOC_LITERAL(4, 62, 4), // "name"
QT_MOC_LITERAL(5, 67, 22), // "ResultData::RecordData"
QT_MOC_LITERAL(6, 90, 6), // "result"
QT_MOC_LITERAL(7, 97, 8), // "isUpload"
QT_MOC_LITERAL(8, 106, 25), // "AddCalibrateRecordSignals"
QT_MOC_LITERAL(9, 132, 23), // "AddCalibrateRecordSlots"
QT_MOC_LITERAL(10, 156, 10), // "BackupFile"
QT_MOC_LITERAL(11, 167, 21) // "AddMeasureRecordSlots"

    },
    "Result::ResultManager\0AddMeasureRecordSignals\0"
    "\0System::String\0name\0ResultData::RecordData\0"
    "result\0isUpload\0AddCalibrateRecordSignals\0"
    "AddCalibrateRecordSlots\0BackupFile\0"
    "AddMeasureRecordSlots"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_Result__ResultManager[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    3,   39,    2, 0x06 /* Public */,
       8,    2,   46,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       9,    2,   51,    2, 0x0a /* Public */,
      10,    0,   56,    2, 0x0a /* Public */,
      11,    3,   57,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3, 0x80000000 | 5, QMetaType::Bool,    4,    6,    7,
    QMetaType::Void, 0x80000000 | 3, 0x80000000 | 5,    4,    6,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3, 0x80000000 | 5,    4,    6,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 3, 0x80000000 | 5, QMetaType::Bool,    4,    6,    7,

       0        // eod
};

void Result::ResultManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        ResultManager *_t = static_cast<ResultManager *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->AddMeasureRecordSignals((*reinterpret_cast< System::String(*)>(_a[1])),(*reinterpret_cast< ResultData::RecordData(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 1: _t->AddCalibrateRecordSignals((*reinterpret_cast< System::String(*)>(_a[1])),(*reinterpret_cast< ResultData::RecordData(*)>(_a[2]))); break;
        case 2: _t->AddCalibrateRecordSlots((*reinterpret_cast< System::String(*)>(_a[1])),(*reinterpret_cast< ResultData::RecordData(*)>(_a[2]))); break;
        case 3: _t->BackupFile(); break;
        case 4: _t->AddMeasureRecordSlots((*reinterpret_cast< System::String(*)>(_a[1])),(*reinterpret_cast< ResultData::RecordData(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 0:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 1:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< ResultData::RecordData >(); break;
            }
            break;
        case 1:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 1:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< ResultData::RecordData >(); break;
            }
            break;
        case 2:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 1:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< ResultData::RecordData >(); break;
            }
            break;
        case 4:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 1:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< ResultData::RecordData >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (ResultManager::*_t)(System::String , ResultData::RecordData , bool );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&ResultManager::AddMeasureRecordSignals)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (ResultManager::*_t)(System::String , ResultData::RecordData );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&ResultManager::AddCalibrateRecordSignals)) {
                *result = 1;
                return;
            }
        }
    }
}

const QMetaObject Result::ResultManager::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_Result__ResultManager.data,
      qt_meta_data_Result__ResultManager,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *Result::ResultManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Result::ResultManager::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_Result__ResultManager.stringdata0))
        return static_cast<void*>(const_cast< ResultManager*>(this));
    return QObject::qt_metacast(_clname);
}

int Result::ResultManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void Result::ResultManager::AddMeasureRecordSignals(System::String _t1, ResultData::RecordData _t2, bool _t3)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)), const_cast<void*>(reinterpret_cast<const void*>(&_t3)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void Result::ResultManager::AddCalibrateRecordSignals(System::String _t1, ResultData::RecordData _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
