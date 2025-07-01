/****************************************************************************
** Meta object code from reading C++ file 'BottomWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Frame/BottomWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'BottomWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__BottomWidget_t {
    QByteArrayData data[9];
    char stringdata0[134];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__BottomWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__BottomWidget_t qt_meta_stringdata_UI__BottomWidget = {
    {
QT_MOC_LITERAL(0, 0, 16), // "UI::BottomWidget"
QT_MOC_LITERAL(1, 17, 23), // "ChangeWqimcStatusSignal"
QT_MOC_LITERAL(2, 41, 0), // ""
QT_MOC_LITERAL(3, 42, 17), // "AlamChangedSignal"
QT_MOC_LITERAL(4, 60, 5), // "level"
QT_MOC_LITERAL(5, 66, 18), // "slotUpdataDateTime"
QT_MOC_LITERAL(6, 85, 10), // "ClearAlarm"
QT_MOC_LITERAL(7, 96, 21), // "ChangeWqimcStatusSlot"
QT_MOC_LITERAL(8, 118, 15) // "AlamChangedSlot"

    },
    "UI::BottomWidget\0ChangeWqimcStatusSignal\0"
    "\0AlamChangedSignal\0level\0slotUpdataDateTime\0"
    "ClearAlarm\0ChangeWqimcStatusSlot\0"
    "AlamChangedSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__BottomWidget[] = {

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
       5,    0,   48,    2, 0x08 /* Private */,
       6,    0,   49,    2, 0x08 /* Private */,
       7,    0,   50,    2, 0x08 /* Private */,
       8,    1,   51,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,

       0        // eod
};

void UI::BottomWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        BottomWidget *_t = static_cast<BottomWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->ChangeWqimcStatusSignal(); break;
        case 1: _t->AlamChangedSignal((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 2: _t->slotUpdataDateTime(); break;
        case 3: _t->ClearAlarm(); break;
        case 4: _t->ChangeWqimcStatusSlot(); break;
        case 5: _t->AlamChangedSlot((*reinterpret_cast< QString(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (BottomWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&BottomWidget::ChangeWqimcStatusSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (BottomWidget::*_t)(QString );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&BottomWidget::AlamChangedSignal)) {
                *result = 1;
                return;
            }
        }
    }
}

const QMetaObject UI::BottomWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__BottomWidget.data,
      qt_meta_data_UI__BottomWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::BottomWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::BottomWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__BottomWidget.stringdata0))
        return static_cast<void*>(const_cast< BottomWidget*>(this));
    if (!strcmp(_clname, "IStatusNotifiable"))
        return static_cast< IStatusNotifiable*>(const_cast< BottomWidget*>(this));
    if (!strcmp(_clname, "IAlarmNotifiable"))
        return static_cast< IAlarmNotifiable*>(const_cast< BottomWidget*>(this));
    if (!strcmp(_clname, "IUpdateSignalNotifiable"))
        return static_cast< IUpdateSignalNotifiable*>(const_cast< BottomWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< BottomWidget*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< BottomWidget*>(this));
    if (!strcmp(_clname, "Interface::Wqimc::IWqimcStatusNotifiable"))
        return static_cast< Interface::Wqimc::IWqimcStatusNotifiable*>(const_cast< BottomWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::BottomWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
void UI::BottomWidget::ChangeWqimcStatusSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void UI::BottomWidget::AlamChangedSignal(QString _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
