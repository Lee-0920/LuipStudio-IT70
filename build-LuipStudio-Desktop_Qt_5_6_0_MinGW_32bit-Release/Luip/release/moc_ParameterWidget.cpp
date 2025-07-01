/****************************************************************************
** Meta object code from reading C++ file 'ParameterWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Setting/ParameterWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ParameterWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__ParameterWidget_t {
    QByteArrayData data[18];
    char stringdata0[274];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__ParameterWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__ParameterWidget_t qt_meta_stringdata_UI__ParameterWidget = {
    {
QT_MOC_LITERAL(0, 0, 19), // "UI::ParameterWidget"
QT_MOC_LITERAL(1, 20, 18), // "DefaultRestoreSlot"
QT_MOC_LITERAL(2, 39, 0), // ""
QT_MOC_LITERAL(3, 40, 17), // "ConfigRefreshSlot"
QT_MOC_LITERAL(4, 58, 17), // "DoubleClickedSlot"
QT_MOC_LITERAL(5, 76, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(6, 94, 4), // "item"
QT_MOC_LITERAL(7, 99, 14), // "CheckValueSlot"
QT_MOC_LITERAL(8, 114, 15), // "ChangeIndexSlot"
QT_MOC_LITERAL(9, 130, 5), // "index"
QT_MOC_LITERAL(10, 136, 24), // "CalibrateChangeIndexSlot"
QT_MOC_LITERAL(11, 161, 24), // "RangeNum1ChangeIndexSlot"
QT_MOC_LITERAL(12, 186, 24), // "RangeNum2ChangeIndexSlot"
QT_MOC_LITERAL(13, 211, 24), // "RangeNum3ChangeIndexSlot"
QT_MOC_LITERAL(14, 236, 12), // "GetPointSize"
QT_MOC_LITERAL(15, 249, 8), // "QString&"
QT_MOC_LITERAL(16, 258, 4), // "text"
QT_MOC_LITERAL(17, 263, 10) // "limitWidth"

    },
    "UI::ParameterWidget\0DefaultRestoreSlot\0"
    "\0ConfigRefreshSlot\0DoubleClickedSlot\0"
    "QTableWidgetItem*\0item\0CheckValueSlot\0"
    "ChangeIndexSlot\0index\0CalibrateChangeIndexSlot\0"
    "RangeNum1ChangeIndexSlot\0"
    "RangeNum2ChangeIndexSlot\0"
    "RangeNum3ChangeIndexSlot\0GetPointSize\0"
    "QString&\0text\0limitWidth"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__ParameterWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      10,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   64,    2, 0x08 /* Private */,
       3,    0,   65,    2, 0x08 /* Private */,
       4,    1,   66,    2, 0x08 /* Private */,
       7,    1,   69,    2, 0x08 /* Private */,
       8,    1,   72,    2, 0x08 /* Private */,
      10,    1,   75,    2, 0x08 /* Private */,
      11,    1,   78,    2, 0x08 /* Private */,
      12,    1,   81,    2, 0x08 /* Private */,
      13,    1,   84,    2, 0x08 /* Private */,
      14,    2,   87,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void, QMetaType::Int,    9,
    QMetaType::Void, QMetaType::Int,    9,
    QMetaType::Void, QMetaType::Int,    2,
    QMetaType::Void, QMetaType::Int,    2,
    QMetaType::Void, QMetaType::Int,    2,
    QMetaType::Int, 0x80000000 | 15, QMetaType::Int,   16,   17,

       0        // eod
};

void UI::ParameterWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        ParameterWidget *_t = static_cast<ParameterWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->DefaultRestoreSlot(); break;
        case 1: _t->ConfigRefreshSlot(); break;
        case 2: _t->DoubleClickedSlot((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 3: _t->CheckValueSlot((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 4: _t->ChangeIndexSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 5: _t->CalibrateChangeIndexSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 6: _t->RangeNum1ChangeIndexSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 7: _t->RangeNum2ChangeIndexSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 8: _t->RangeNum3ChangeIndexSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 9: { int _r = _t->GetPointSize((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        default: ;
        }
    }
}

const QMetaObject UI::ParameterWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__ParameterWidget.data,
      qt_meta_data_UI__ParameterWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::ParameterWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::ParameterWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__ParameterWidget.stringdata0))
        return static_cast<void*>(const_cast< ParameterWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< ParameterWidget*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< ParameterWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::ParameterWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 10;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
