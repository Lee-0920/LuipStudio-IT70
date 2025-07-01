/****************************************************************************
** Meta object code from reading C++ file 'PeakShapeWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Singal/PeakShapeWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'PeakShapeWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__PeakShape_t {
    QByteArrayData data[10];
    char stringdata0[135];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__PeakShape_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__PeakShape_t qt_meta_stringdata_UI__PeakShape = {
    {
QT_MOC_LITERAL(0, 0, 13), // "UI::PeakShape"
QT_MOC_LITERAL(1, 14, 15), // "SlotUpdaterData"
QT_MOC_LITERAL(2, 30, 0), // ""
QT_MOC_LITERAL(3, 31, 15), // "SlotRangeChange"
QT_MOC_LITERAL(4, 47, 18), // "SlotPeakhighChange"
QT_MOC_LITERAL(5, 66, 3), // "arg"
QT_MOC_LITERAL(6, 70, 11), // "SlotAddTopY"
QT_MOC_LITERAL(7, 82, 17), // "SlotSubstractTopY"
QT_MOC_LITERAL(8, 100, 14), // "SlotAddBottomY"
QT_MOC_LITERAL(9, 115, 19) // "SlotSubtractBottomY"

    },
    "UI::PeakShape\0SlotUpdaterData\0\0"
    "SlotRangeChange\0SlotPeakhighChange\0"
    "arg\0SlotAddTopY\0SlotSubstractTopY\0"
    "SlotAddBottomY\0SlotSubtractBottomY"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__PeakShape[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       7,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   49,    2, 0x08 /* Private */,
       3,    0,   50,    2, 0x08 /* Private */,
       4,    1,   51,    2, 0x08 /* Private */,
       6,    0,   54,    2, 0x08 /* Private */,
       7,    0,   55,    2, 0x08 /* Private */,
       8,    0,   56,    2, 0x08 /* Private */,
       9,    0,   57,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    5,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void UI::PeakShape::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        PeakShape *_t = static_cast<PeakShape *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SlotUpdaterData(); break;
        case 1: _t->SlotRangeChange(); break;
        case 2: _t->SlotPeakhighChange((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 3: _t->SlotAddTopY(); break;
        case 4: _t->SlotSubstractTopY(); break;
        case 5: _t->SlotAddBottomY(); break;
        case 6: _t->SlotSubtractBottomY(); break;
        default: ;
        }
    }
}

const QMetaObject UI::PeakShape::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__PeakShape.data,
      qt_meta_data_UI__PeakShape,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::PeakShape::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::PeakShape::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__PeakShape.stringdata0))
        return static_cast<void*>(const_cast< PeakShape*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< PeakShape*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::PeakShape::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 7)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 7;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 7)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 7;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
