/****************************************************************************
** Meta object code from reading C++ file 'MotorManagerWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../IM70TOC-LuipStudio/LuipStudio/Luip/UI/Maintain/MotorManagerWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'MotorManagerWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__MotorManagerWidget_t {
    QByteArrayData data[9];
    char stringdata0[98];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__MotorManagerWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__MotorManagerWidget_t qt_meta_stringdata_UI__MotorManagerWidget = {
    {
QT_MOC_LITERAL(0, 0, 22), // "UI::MotorManagerWidget"
QT_MOC_LITERAL(1, 23, 12), // "MeasureStart"
QT_MOC_LITERAL(2, 36, 0), // ""
QT_MOC_LITERAL(3, 37, 5), // "index"
QT_MOC_LITERAL(4, 43, 8), // "ChoseDay"
QT_MOC_LITERAL(5, 52, 11), // "StopMeasure"
QT_MOC_LITERAL(6, 64, 10), // "CheckValue"
QT_MOC_LITERAL(7, 75, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(8, 93, 4) // "item"

    },
    "UI::MotorManagerWidget\0MeasureStart\0"
    "\0index\0ChoseDay\0StopMeasure\0CheckValue\0"
    "QTableWidgetItem*\0item"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__MotorManagerWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    1,   34,    2, 0x08 /* Private */,
       4,    0,   37,    2, 0x08 /* Private */,
       5,    0,   38,    2, 0x08 /* Private */,
       6,    1,   39,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void, QMetaType::Int,    3,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 7,    8,

       0        // eod
};

void UI::MotorManagerWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        MotorManagerWidget *_t = static_cast<MotorManagerWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->MeasureStart((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->ChoseDay(); break;
        case 2: _t->StopMeasure(); break;
        case 3: _t->CheckValue((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject UI::MotorManagerWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__MotorManagerWidget.data,
      qt_meta_data_UI__MotorManagerWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::MotorManagerWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::MotorManagerWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__MotorManagerWidget.stringdata0))
        return static_cast<void*>(const_cast< MotorManagerWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< MotorManagerWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::MotorManagerWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 4)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 4;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
