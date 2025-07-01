/****************************************************************************
** Meta object code from reading C++ file 'UpdateWidgetManager.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Frame/UpdateWidgetManager.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'UpdateWidgetManager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__UpdateWidgetManager_t {
    QByteArrayData data[8];
    char stringdata0[100];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__UpdateWidgetManager_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__UpdateWidgetManager_t qt_meta_stringdata_UI__UpdateWidgetManager = {
    {
QT_MOC_LITERAL(0, 0, 23), // "UI::UpdateWidgetManager"
QT_MOC_LITERAL(1, 24, 12), // "UpdateWidget"
QT_MOC_LITERAL(2, 37, 0), // ""
QT_MOC_LITERAL(3, 38, 15), // "UI::UpdateEvent"
QT_MOC_LITERAL(4, 54, 5), // "event"
QT_MOC_LITERAL(5, 60, 14), // "System::String"
QT_MOC_LITERAL(6, 75, 7), // "message"
QT_MOC_LITERAL(7, 83, 16) // "SlotUpdateWidget"

    },
    "UI::UpdateWidgetManager\0UpdateWidget\0"
    "\0UI::UpdateEvent\0event\0System::String\0"
    "message\0SlotUpdateWidget"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__UpdateWidgetManager[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       3,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    2,   29,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       7,    2,   34,    2, 0x0a /* Public */,
       7,    1,   39,    2, 0x2a /* Public | MethodCloned */,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3, 0x80000000 | 5,    4,    6,

 // slots: parameters
    QMetaType::Void, 0x80000000 | 3, 0x80000000 | 5,    4,    6,
    QMetaType::Void, 0x80000000 | 3,    4,

       0        // eod
};

void UI::UpdateWidgetManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        UpdateWidgetManager *_t = static_cast<UpdateWidgetManager *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->UpdateWidget((*reinterpret_cast< UI::UpdateEvent(*)>(_a[1])),(*reinterpret_cast< System::String(*)>(_a[2]))); break;
        case 1: _t->SlotUpdateWidget((*reinterpret_cast< UI::UpdateEvent(*)>(_a[1])),(*reinterpret_cast< System::String(*)>(_a[2]))); break;
        case 2: _t->SlotUpdateWidget((*reinterpret_cast< UI::UpdateEvent(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 0:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 1:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< System::String >(); break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< UI::UpdateEvent >(); break;
            }
            break;
        case 1:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 1:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< System::String >(); break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< UI::UpdateEvent >(); break;
            }
            break;
        case 2:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< UI::UpdateEvent >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (UpdateWidgetManager::*_t)(UI::UpdateEvent , System::String );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&UpdateWidgetManager::UpdateWidget)) {
                *result = 0;
                return;
            }
        }
    }
}

const QMetaObject UI::UpdateWidgetManager::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_UI__UpdateWidgetManager.data,
      qt_meta_data_UI__UpdateWidgetManager,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::UpdateWidgetManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::UpdateWidgetManager::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__UpdateWidgetManager.stringdata0))
        return static_cast<void*>(const_cast< UpdateWidgetManager*>(this));
    return QObject::qt_metacast(_clname);
}

int UI::UpdateWidgetManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 3)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 3)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    }
    return _id;
}

// SIGNAL 0
void UI::UpdateWidgetManager::UpdateWidget(UI::UpdateEvent _t1, System::String _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
