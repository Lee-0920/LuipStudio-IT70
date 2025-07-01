/****************************************************************************
** Meta object code from reading C++ file 'ReagentManagerWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Maintain/ReagentManagerWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ReagentManagerWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__ReagentManagerWidget_t {
    QByteArrayData data[9];
    char stringdata0[138];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__ReagentManagerWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__ReagentManagerWidget_t qt_meta_stringdata_UI__ReagentManagerWidget = {
    {
QT_MOC_LITERAL(0, 0, 24), // "UI::ReagentManagerWidget"
QT_MOC_LITERAL(1, 25, 14), // "SlotUseMeasure"
QT_MOC_LITERAL(2, 40, 0), // ""
QT_MOC_LITERAL(3, 41, 17), // "slotDoubleClicked"
QT_MOC_LITERAL(4, 59, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(5, 77, 4), // "item"
QT_MOC_LITERAL(6, 82, 10), // "CheckValue"
QT_MOC_LITERAL(7, 93, 20), // "SlotReagentDateCheck"
QT_MOC_LITERAL(8, 114, 23) // "SlotOneKeyChangeReagent"

    },
    "UI::ReagentManagerWidget\0SlotUseMeasure\0"
    "\0slotDoubleClicked\0QTableWidgetItem*\0"
    "item\0CheckValue\0SlotReagentDateCheck\0"
    "SlotOneKeyChangeReagent"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__ReagentManagerWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   39,    2, 0x08 /* Private */,
       3,    1,   42,    2, 0x08 /* Private */,
       6,    1,   45,    2, 0x08 /* Private */,
       7,    0,   48,    2, 0x08 /* Private */,
       8,    0,   49,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, QMetaType::Int,    2,
    QMetaType::Void, 0x80000000 | 4,    5,
    QMetaType::Void, 0x80000000 | 4,    5,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void UI::ReagentManagerWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        ReagentManagerWidget *_t = static_cast<ReagentManagerWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SlotUseMeasure((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->slotDoubleClicked((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 2: _t->CheckValue((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 3: _t->SlotReagentDateCheck(); break;
        case 4: _t->SlotOneKeyChangeReagent(); break;
        default: ;
        }
    }
}

const QMetaObject UI::ReagentManagerWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__ReagentManagerWidget.data,
      qt_meta_data_UI__ReagentManagerWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::ReagentManagerWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::ReagentManagerWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__ReagentManagerWidget.stringdata0))
        return static_cast<void*>(const_cast< ReagentManagerWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< ReagentManagerWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::ReagentManagerWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 5;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
