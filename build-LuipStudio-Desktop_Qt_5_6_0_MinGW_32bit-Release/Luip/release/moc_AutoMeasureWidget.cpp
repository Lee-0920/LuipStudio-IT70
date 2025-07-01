/****************************************************************************
** Meta object code from reading C++ file 'AutoMeasureWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Setting/AutoMeasureWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'AutoMeasureWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__AutoMeasureWidget_t {
    QByteArrayData data[14];
    char stringdata0[194];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__AutoMeasureWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__AutoMeasureWidget_t qt_meta_stringdata_UI__AutoMeasureWidget = {
    {
QT_MOC_LITERAL(0, 0, 21), // "UI::AutoMeasureWidget"
QT_MOC_LITERAL(1, 22, 18), // "DefaultRestoreSlot"
QT_MOC_LITERAL(2, 41, 0), // ""
QT_MOC_LITERAL(3, 42, 17), // "ConfigRefreshSlot"
QT_MOC_LITERAL(4, 60, 17), // "DoubleClickedSlot"
QT_MOC_LITERAL(5, 78, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(6, 96, 4), // "item"
QT_MOC_LITERAL(7, 101, 14), // "CheckValueSlot"
QT_MOC_LITERAL(8, 116, 15), // "OneCheckOddSlot"
QT_MOC_LITERAL(9, 132, 16), // "OneCheckEvenSlot"
QT_MOC_LITERAL(10, 149, 15), // "OneCheckAllSlot"
QT_MOC_LITERAL(11, 165, 17), // "SetPointCheckSlot"
QT_MOC_LITERAL(12, 183, 5), // "index"
QT_MOC_LITERAL(13, 189, 4) // "time"

    },
    "UI::AutoMeasureWidget\0DefaultRestoreSlot\0"
    "\0ConfigRefreshSlot\0DoubleClickedSlot\0"
    "QTableWidgetItem*\0item\0CheckValueSlot\0"
    "OneCheckOddSlot\0OneCheckEvenSlot\0"
    "OneCheckAllSlot\0SetPointCheckSlot\0"
    "index\0time"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__AutoMeasureWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   59,    2, 0x08 /* Private */,
       3,    0,   60,    2, 0x08 /* Private */,
       4,    1,   61,    2, 0x08 /* Private */,
       7,    1,   64,    2, 0x08 /* Private */,
       8,    0,   67,    2, 0x08 /* Private */,
       9,    0,   68,    2, 0x08 /* Private */,
      10,    0,   69,    2, 0x08 /* Private */,
      11,    1,   70,    2, 0x08 /* Private */,
      13,    0,   73,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,   12,
    QMetaType::Void,

       0        // eod
};

void UI::AutoMeasureWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        AutoMeasureWidget *_t = static_cast<AutoMeasureWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->DefaultRestoreSlot(); break;
        case 1: _t->ConfigRefreshSlot(); break;
        case 2: _t->DoubleClickedSlot((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 3: _t->CheckValueSlot((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 4: _t->OneCheckOddSlot(); break;
        case 5: _t->OneCheckEvenSlot(); break;
        case 6: _t->OneCheckAllSlot(); break;
        case 7: _t->SetPointCheckSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 8: _t->time(); break;
        default: ;
        }
    }
}

const QMetaObject UI::AutoMeasureWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__AutoMeasureWidget.data,
      qt_meta_data_UI__AutoMeasureWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::AutoMeasureWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::AutoMeasureWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__AutoMeasureWidget.stringdata0))
        return static_cast<void*>(const_cast< AutoMeasureWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< AutoMeasureWidget*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< AutoMeasureWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::AutoMeasureWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 9;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
