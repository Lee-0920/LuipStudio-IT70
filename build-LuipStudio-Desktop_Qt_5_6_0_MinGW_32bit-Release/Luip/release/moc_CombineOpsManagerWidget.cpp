/****************************************************************************
** Meta object code from reading C++ file 'CombineOpsManagerWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Maintain/CombineOpsManagerWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'CombineOpsManagerWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__CombineOpsManagerWidget_t {
    QByteArrayData data[11];
    char stringdata0[138];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__CombineOpsManagerWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__CombineOpsManagerWidget_t qt_meta_stringdata_UI__CombineOpsManagerWidget = {
    {
QT_MOC_LITERAL(0, 0, 27), // "UI::CombineOpsManagerWidget"
QT_MOC_LITERAL(1, 28, 12), // "MeasureStart"
QT_MOC_LITERAL(2, 41, 0), // ""
QT_MOC_LITERAL(3, 42, 5), // "index"
QT_MOC_LITERAL(4, 48, 8), // "ChoseDay"
QT_MOC_LITERAL(5, 57, 11), // "StopMeasure"
QT_MOC_LITERAL(6, 69, 10), // "CheckValue"
QT_MOC_LITERAL(7, 80, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(8, 98, 4), // "item"
QT_MOC_LITERAL(9, 103, 16), // "SlotIndexChanged"
QT_MOC_LITERAL(10, 120, 17) // "SlotDoubleClicked"

    },
    "UI::CombineOpsManagerWidget\0MeasureStart\0"
    "\0index\0ChoseDay\0StopMeasure\0CheckValue\0"
    "QTableWidgetItem*\0item\0SlotIndexChanged\0"
    "SlotDoubleClicked"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__CombineOpsManagerWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   44,    2, 0x08 /* Private */,
       4,    0,   47,    2, 0x08 /* Private */,
       5,    0,   48,    2, 0x08 /* Private */,
       6,    1,   49,    2, 0x08 /* Private */,
       9,    1,   52,    2, 0x08 /* Private */,
      10,    1,   55,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, QMetaType::Int,    3,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void, QMetaType::Int,    2,
    QMetaType::Void, 0x80000000 | 7,    8,

       0        // eod
};

void UI::CombineOpsManagerWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        CombineOpsManagerWidget *_t = static_cast<CombineOpsManagerWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->MeasureStart((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->ChoseDay(); break;
        case 2: _t->StopMeasure(); break;
        case 3: _t->CheckValue((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 4: _t->SlotIndexChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 5: _t->SlotDoubleClicked((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject UI::CombineOpsManagerWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__CombineOpsManagerWidget.data,
      qt_meta_data_UI__CombineOpsManagerWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::CombineOpsManagerWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::CombineOpsManagerWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__CombineOpsManagerWidget.stringdata0))
        return static_cast<void*>(const_cast< CombineOpsManagerWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< CombineOpsManagerWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::CombineOpsManagerWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
QT_END_MOC_NAMESPACE
