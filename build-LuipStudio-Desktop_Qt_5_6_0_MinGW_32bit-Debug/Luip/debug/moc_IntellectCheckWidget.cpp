/****************************************************************************
** Meta object code from reading C++ file 'IntellectCheckWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Maintain/IntellectCheckWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'IntellectCheckWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__IntellectCheck_t {
    QByteArrayData data[10];
    char stringdata0[148];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__IntellectCheck_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__IntellectCheck_t qt_meta_stringdata_UI__IntellectCheck = {
    {
QT_MOC_LITERAL(0, 0, 18), // "UI::IntellectCheck"
QT_MOC_LITERAL(1, 19, 28), // "UpdateItemCheckMessageSignal"
QT_MOC_LITERAL(2, 48, 0), // ""
QT_MOC_LITERAL(3, 49, 4), // "name"
QT_MOC_LITERAL(4, 54, 3), // "mag"
QT_MOC_LITERAL(5, 58, 14), // "OneCheckConfig"
QT_MOC_LITERAL(6, 73, 14), // "SlotStopDetect"
QT_MOC_LITERAL(7, 88, 17), // "OneCheckAllConfig"
QT_MOC_LITERAL(8, 106, 14), // "SlotOneKeyStop"
QT_MOC_LITERAL(9, 121, 26) // "UpdateItemCheckMessageSlot"

    },
    "UI::IntellectCheck\0UpdateItemCheckMessageSignal\0"
    "\0name\0mag\0OneCheckConfig\0SlotStopDetect\0"
    "OneCheckAllConfig\0SlotOneKeyStop\0"
    "UpdateItemCheckMessageSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__IntellectCheck[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    2,   44,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       5,    0,   49,    2, 0x08 /* Private */,
       6,    0,   50,    2, 0x08 /* Private */,
       7,    0,   51,    2, 0x08 /* Private */,
       8,    0,   52,    2, 0x08 /* Private */,
       9,    2,   53,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    3,    4,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    3,    4,

       0        // eod
};

void UI::IntellectCheck::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        IntellectCheck *_t = static_cast<IntellectCheck *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->UpdateItemCheckMessageSignal((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        case 1: _t->OneCheckConfig(); break;
        case 2: _t->SlotStopDetect(); break;
        case 3: _t->OneCheckAllConfig(); break;
        case 4: _t->SlotOneKeyStop(); break;
        case 5: _t->UpdateItemCheckMessageSlot((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< QString(*)>(_a[2]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (IntellectCheck::*_t)(QString , QString );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&IntellectCheck::UpdateItemCheckMessageSignal)) {
                *result = 0;
                return;
            }
        }
    }
}

const QMetaObject UI::IntellectCheck::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__IntellectCheck.data,
      qt_meta_data_UI__IntellectCheck,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::IntellectCheck::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::IntellectCheck::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__IntellectCheck.stringdata0))
        return static_cast<void*>(const_cast< IntellectCheck*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< IntellectCheck*>(this));
    if (!strcmp(_clname, "IFlowNotifiable"))
        return static_cast< IFlowNotifiable*>(const_cast< IntellectCheck*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< IntellectCheck*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::IntellectCheck::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
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
void UI::IntellectCheck::UpdateItemCheckMessageSignal(QString _t1, QString _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
