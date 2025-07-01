/****************************************************************************
** Meta object code from reading C++ file 'MeasureDataPrintWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Data/MeasureDataPrintWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'MeasureDataPrintWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__MeasureDataPrintWidget_t {
    QByteArrayData data[11];
    char stringdata0[193];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__MeasureDataPrintWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__MeasureDataPrintWidget_t qt_meta_stringdata_UI__MeasureDataPrintWidget = {
    {
QT_MOC_LITERAL(0, 0, 26), // "UI::MeasureDataPrintWidget"
QT_MOC_LITERAL(1, 27, 25), // "SignalPrintNewMeasureData"
QT_MOC_LITERAL(2, 53, 0), // ""
QT_MOC_LITERAL(3, 54, 15), // "SlotPrintButton"
QT_MOC_LITERAL(4, 70, 17), // "SlotConnectButton"
QT_MOC_LITERAL(5, 88, 15), // "SlotCloseButton"
QT_MOC_LITERAL(6, 104, 13), // "SlotCutButton"
QT_MOC_LITERAL(7, 118, 14), // "SlotHeadButton"
QT_MOC_LITERAL(8, 133, 18), // "SlotBeginTimeCheck"
QT_MOC_LITERAL(9, 152, 16), // "SlotEndTimeCheck"
QT_MOC_LITERAL(10, 169, 23) // "SlotPrintNewMeasureData"

    },
    "UI::MeasureDataPrintWidget\0"
    "SignalPrintNewMeasureData\0\0SlotPrintButton\0"
    "SlotConnectButton\0SlotCloseButton\0"
    "SlotCutButton\0SlotHeadButton\0"
    "SlotBeginTimeCheck\0SlotEndTimeCheck\0"
    "SlotPrintNewMeasureData"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__MeasureDataPrintWidget[] = {

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
       1,    0,   59,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       3,    0,   60,    2, 0x08 /* Private */,
       4,    0,   61,    2, 0x08 /* Private */,
       5,    0,   62,    2, 0x08 /* Private */,
       6,    0,   63,    2, 0x08 /* Private */,
       7,    0,   64,    2, 0x08 /* Private */,
       8,    1,   65,    2, 0x08 /* Private */,
       9,    1,   68,    2, 0x08 /* Private */,
      10,    0,   71,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QDateTime,    2,
    QMetaType::Void, QMetaType::QDateTime,    2,
    QMetaType::Void,

       0        // eod
};

void UI::MeasureDataPrintWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        MeasureDataPrintWidget *_t = static_cast<MeasureDataPrintWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SignalPrintNewMeasureData(); break;
        case 1: _t->SlotPrintButton(); break;
        case 2: _t->SlotConnectButton(); break;
        case 3: _t->SlotCloseButton(); break;
        case 4: _t->SlotCutButton(); break;
        case 5: _t->SlotHeadButton(); break;
        case 6: _t->SlotBeginTimeCheck((*reinterpret_cast< QDateTime(*)>(_a[1]))); break;
        case 7: _t->SlotEndTimeCheck((*reinterpret_cast< QDateTime(*)>(_a[1]))); break;
        case 8: _t->SlotPrintNewMeasureData(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (MeasureDataPrintWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureDataPrintWidget::SignalPrintNewMeasureData)) {
                *result = 0;
                return;
            }
        }
    }
}

const QMetaObject UI::MeasureDataPrintWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__MeasureDataPrintWidget.data,
      qt_meta_data_UI__MeasureDataPrintWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::MeasureDataPrintWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::MeasureDataPrintWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__MeasureDataPrintWidget.stringdata0))
        return static_cast<void*>(const_cast< MeasureDataPrintWidget*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< MeasureDataPrintWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::MeasureDataPrintWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
void UI::MeasureDataPrintWidget::SignalPrintNewMeasureData()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
