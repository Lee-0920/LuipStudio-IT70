/****************************************************************************
** Meta object code from reading C++ file 'InstrumentInformationWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/System/InstrumentInformationWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'InstrumentInformationWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__InstrumentInformationWidget_t {
    QByteArrayData data[4];
    char stringdata0[64];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__InstrumentInformationWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__InstrumentInformationWidget_t qt_meta_stringdata_UI__InstrumentInformationWidget = {
    {
QT_MOC_LITERAL(0, 0, 31), // "UI::InstrumentInformationWidget"
QT_MOC_LITERAL(1, 32, 15), // "SlotSetSNButton"
QT_MOC_LITERAL(2, 48, 0), // ""
QT_MOC_LITERAL(3, 49, 14) // "UpdateQrencode"

    },
    "UI::InstrumentInformationWidget\0"
    "SlotSetSNButton\0\0UpdateQrencode"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__InstrumentInformationWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   24,    2, 0x08 /* Private */,
       3,    0,   25,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void UI::InstrumentInformationWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        InstrumentInformationWidget *_t = static_cast<InstrumentInformationWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SlotSetSNButton(); break;
        case 1: _t->UpdateQrencode(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObject UI::InstrumentInformationWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__InstrumentInformationWidget.data,
      qt_meta_data_UI__InstrumentInformationWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::InstrumentInformationWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::InstrumentInformationWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__InstrumentInformationWidget.stringdata0))
        return static_cast<void*>(const_cast< InstrumentInformationWidget*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< InstrumentInformationWidget*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< InstrumentInformationWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::InstrumentInformationWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 2)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 2)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 2;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
