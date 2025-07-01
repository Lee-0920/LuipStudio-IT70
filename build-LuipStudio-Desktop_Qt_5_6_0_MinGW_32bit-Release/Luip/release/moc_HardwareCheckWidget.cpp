/****************************************************************************
** Meta object code from reading C++ file 'HardwareCheckWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Maintain/HardwareCheckWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'HardwareCheckWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__HardwareCheckWidget_t {
    QByteArrayData data[17];
    char stringdata0[244];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__HardwareCheckWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__HardwareCheckWidget_t qt_meta_stringdata_UI__HardwareCheckWidget = {
    {
QT_MOC_LITERAL(0, 0, 23), // "UI::HardwareCheckWidget"
QT_MOC_LITERAL(1, 24, 22), // "UpdatePumpFactorSignal"
QT_MOC_LITERAL(2, 47, 0), // ""
QT_MOC_LITERAL(3, 48, 6), // "result"
QT_MOC_LITERAL(4, 55, 14), // "SlotUpdateData"
QT_MOC_LITERAL(5, 70, 15), // "SlotChangeParam"
QT_MOC_LITERAL(6, 86, 17), // "SlotDoubleClicked"
QT_MOC_LITERAL(7, 104, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(8, 122, 4), // "item"
QT_MOC_LITERAL(9, 127, 17), // "ConfigApplication"
QT_MOC_LITERAL(10, 145, 23), // "SlotTempCalibrateButton"
QT_MOC_LITERAL(11, 169, 25), // "SlotExTempCalibrateButton"
QT_MOC_LITERAL(12, 195, 10), // "CheckValue"
QT_MOC_LITERAL(13, 206, 12), // "GetPointSize"
QT_MOC_LITERAL(14, 219, 8), // "QString&"
QT_MOC_LITERAL(15, 228, 4), // "text"
QT_MOC_LITERAL(16, 233, 10) // "limitWidth"

    },
    "UI::HardwareCheckWidget\0UpdatePumpFactorSignal\0"
    "\0result\0SlotUpdateData\0SlotChangeParam\0"
    "SlotDoubleClicked\0QTableWidgetItem*\0"
    "item\0ConfigApplication\0SlotTempCalibrateButton\0"
    "SlotExTempCalibrateButton\0CheckValue\0"
    "GetPointSize\0QString&\0text\0limitWidth"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__HardwareCheckWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   59,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       4,    0,   62,    2, 0x08 /* Private */,
       5,    0,   63,    2, 0x08 /* Private */,
       6,    1,   64,    2, 0x08 /* Private */,
       9,    0,   67,    2, 0x08 /* Private */,
      10,    0,   68,    2, 0x08 /* Private */,
      11,    0,   69,    2, 0x08 /* Private */,
      12,    1,   70,    2, 0x08 /* Private */,
      13,    2,   73,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void, QMetaType::Float,    3,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Int, 0x80000000 | 14, QMetaType::Int,   15,   16,

       0        // eod
};

void UI::HardwareCheckWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        HardwareCheckWidget *_t = static_cast<HardwareCheckWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->UpdatePumpFactorSignal((*reinterpret_cast< float(*)>(_a[1]))); break;
        case 1: _t->SlotUpdateData(); break;
        case 2: _t->SlotChangeParam(); break;
        case 3: _t->SlotDoubleClicked((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 4: _t->ConfigApplication(); break;
        case 5: _t->SlotTempCalibrateButton(); break;
        case 6: _t->SlotExTempCalibrateButton(); break;
        case 7: _t->CheckValue((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 8: { int _r = _t->GetPointSize((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = _r; }  break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (HardwareCheckWidget::*_t)(float );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&HardwareCheckWidget::UpdatePumpFactorSignal)) {
                *result = 0;
                return;
            }
        }
    }
}

const QMetaObject UI::HardwareCheckWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__HardwareCheckWidget.data,
      qt_meta_data_UI__HardwareCheckWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::HardwareCheckWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::HardwareCheckWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__HardwareCheckWidget.stringdata0))
        return static_cast<void*>(const_cast< HardwareCheckWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< HardwareCheckWidget*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< HardwareCheckWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::HardwareCheckWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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

// SIGNAL 0
void UI::HardwareCheckWidget::UpdatePumpFactorSignal(float _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
