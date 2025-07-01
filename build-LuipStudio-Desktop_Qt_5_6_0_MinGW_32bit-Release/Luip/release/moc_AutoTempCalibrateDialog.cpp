/****************************************************************************
** Meta object code from reading C++ file 'AutoTempCalibrateDialog.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Maintain/AutoTempCalibrateDialog.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'AutoTempCalibrateDialog.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__AutoTempCalibrateDialog_t {
    QByteArrayData data[10];
    char stringdata0[140];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__AutoTempCalibrateDialog_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__AutoTempCalibrateDialog_t qt_meta_stringdata_UI__AutoTempCalibrateDialog = {
    {
QT_MOC_LITERAL(0, 0, 27), // "UI::AutoTempCalibrateDialog"
QT_MOC_LITERAL(1, 28, 14), // "SlotQuitButton"
QT_MOC_LITERAL(2, 43, 0), // ""
QT_MOC_LITERAL(3, 44, 15), // "SlotApplyButton"
QT_MOC_LITERAL(4, 60, 14), // "SlotCheckValue"
QT_MOC_LITERAL(5, 75, 17), // "QTableWidgetItem*"
QT_MOC_LITERAL(6, 93, 4), // "item"
QT_MOC_LITERAL(7, 98, 17), // "SlotDoubleClicked"
QT_MOC_LITERAL(8, 116, 19), // "SlotCalibrateButton"
QT_MOC_LITERAL(9, 136, 3) // "row"

    },
    "UI::AutoTempCalibrateDialog\0SlotQuitButton\0"
    "\0SlotApplyButton\0SlotCheckValue\0"
    "QTableWidgetItem*\0item\0SlotDoubleClicked\0"
    "SlotCalibrateButton\0row"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__AutoTempCalibrateDialog[] = {

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
       1,    0,   39,    2, 0x08 /* Private */,
       3,    0,   40,    2, 0x08 /* Private */,
       4,    1,   41,    2, 0x08 /* Private */,
       7,    1,   44,    2, 0x08 /* Private */,
       8,    1,   47,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void, 0x80000000 | 5,    6,
    QMetaType::Void, QMetaType::Int,    9,

       0        // eod
};

void UI::AutoTempCalibrateDialog::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        AutoTempCalibrateDialog *_t = static_cast<AutoTempCalibrateDialog *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SlotQuitButton(); break;
        case 1: _t->SlotApplyButton(); break;
        case 2: _t->SlotCheckValue((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 3: _t->SlotDoubleClicked((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 4: _t->SlotCalibrateButton((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObject UI::AutoTempCalibrateDialog::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_UI__AutoTempCalibrateDialog.data,
      qt_meta_data_UI__AutoTempCalibrateDialog,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::AutoTempCalibrateDialog::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::AutoTempCalibrateDialog::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__AutoTempCalibrateDialog.stringdata0))
        return static_cast<void*>(const_cast< AutoTempCalibrateDialog*>(this));
    return QDialog::qt_metacast(_clname);
}

int UI::AutoTempCalibrateDialog::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
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
