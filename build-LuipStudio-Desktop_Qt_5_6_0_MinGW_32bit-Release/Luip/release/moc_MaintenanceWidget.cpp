/****************************************************************************
** Meta object code from reading C++ file 'MaintenanceWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Maintain/MaintenanceWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'MaintenanceWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__MaintenanceWidget_t {
    QByteArrayData data[13];
    char stringdata0[217];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__MaintenanceWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__MaintenanceWidget_t qt_meta_stringdata_UI__MaintenanceWidget = {
    {
QT_MOC_LITERAL(0, 0, 21), // "UI::MaintenanceWidget"
QT_MOC_LITERAL(1, 22, 34), // "MaintenanceUpdateFlowMessageS..."
QT_MOC_LITERAL(2, 57, 0), // ""
QT_MOC_LITERAL(3, 58, 33), // "MaintenanceClearFlowMessageSi..."
QT_MOC_LITERAL(4, 92, 21), // "SlotUpdateFlowMessage"
QT_MOC_LITERAL(5, 114, 20), // "SlotClearFlowMessage"
QT_MOC_LITERAL(6, 135, 11), // "StopMeasure"
QT_MOC_LITERAL(7, 147, 9), // "StopStove"
QT_MOC_LITERAL(8, 157, 12), // "measureStart"
QT_MOC_LITERAL(9, 170, 12), // "ShowKeyboard"
QT_MOC_LITERAL(10, 183, 10), // "CheckValue"
QT_MOC_LITERAL(11, 194, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(12, 212, 4) // "item"

    },
    "UI::MaintenanceWidget\0"
    "MaintenanceUpdateFlowMessageSignal\0\0"
    "MaintenanceClearFlowMessageSignal\0"
    "SlotUpdateFlowMessage\0SlotClearFlowMessage\0"
    "StopMeasure\0StopStove\0measureStart\0"
    "ShowKeyboard\0CheckValue\0QTableWidgetItem*\0"
    "item"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__MaintenanceWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   59,    2, 0x06 /* Public */,
       3,    0,   60,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       4,    0,   61,    2, 0x08 /* Private */,
       5,    0,   62,    2, 0x08 /* Private */,
       6,    0,   63,    2, 0x08 /* Private */,
       7,    0,   64,    2, 0x08 /* Private */,
       8,    1,   65,    2, 0x08 /* Private */,
       9,    0,   68,    2, 0x08 /* Private */,
      10,    1,   69,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    2,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 11,   12,

       0        // eod
};

void UI::MaintenanceWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        MaintenanceWidget *_t = static_cast<MaintenanceWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->MaintenanceUpdateFlowMessageSignal(); break;
        case 1: _t->MaintenanceClearFlowMessageSignal(); break;
        case 2: _t->SlotUpdateFlowMessage(); break;
        case 3: _t->SlotClearFlowMessage(); break;
        case 4: _t->StopMeasure(); break;
        case 5: _t->StopStove(); break;
        case 6: _t->measureStart((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 7: _t->ShowKeyboard(); break;
        case 8: _t->CheckValue((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (MaintenanceWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MaintenanceWidget::MaintenanceUpdateFlowMessageSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (MaintenanceWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MaintenanceWidget::MaintenanceClearFlowMessageSignal)) {
                *result = 1;
                return;
            }
        }
    }
}

const QMetaObject UI::MaintenanceWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__MaintenanceWidget.data,
      qt_meta_data_UI__MaintenanceWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::MaintenanceWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::MaintenanceWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__MaintenanceWidget.stringdata0))
        return static_cast<void*>(const_cast< MaintenanceWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< MaintenanceWidget*>(this));
    if (!strcmp(_clname, "IFlowNotifiable"))
        return static_cast< IFlowNotifiable*>(const_cast< MaintenanceWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::MaintenanceWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
void UI::MaintenanceWidget::MaintenanceUpdateFlowMessageSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void UI::MaintenanceWidget::MaintenanceClearFlowMessageSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 1, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
