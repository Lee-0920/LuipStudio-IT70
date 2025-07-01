/****************************************************************************
** Meta object code from reading C++ file 'RunLogWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Data/RunLogWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'RunLogWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__RunLog_t {
    QByteArrayData data[13];
    char stringdata0[135];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__RunLog_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__RunLog_t qt_meta_stringdata_UI__RunLog = {
    {
QT_MOC_LITERAL(0, 0, 10), // "UI::RunLog"
QT_MOC_LITERAL(1, 11, 5), // "ToTop"
QT_MOC_LITERAL(2, 17, 0), // ""
QT_MOC_LITERAL(3, 18, 8), // "ToBottom"
QT_MOC_LITERAL(4, 27, 6), // "ToBack"
QT_MOC_LITERAL(5, 34, 6), // "ToNext"
QT_MOC_LITERAL(6, 41, 11), // "ChoseMinDay"
QT_MOC_LITERAL(7, 53, 11), // "ChoseMaxDay"
QT_MOC_LITERAL(8, 65, 12), // "ChangeMinDay"
QT_MOC_LITERAL(9, 78, 12), // "ChangeMaxDay"
QT_MOC_LITERAL(10, 91, 10), // "ChangePage"
QT_MOC_LITERAL(11, 102, 16), // "SlotExportButton"
QT_MOC_LITERAL(12, 119, 15) // "SlotClearButton"

    },
    "UI::RunLog\0ToTop\0\0ToBottom\0ToBack\0"
    "ToNext\0ChoseMinDay\0ChoseMaxDay\0"
    "ChangeMinDay\0ChangeMaxDay\0ChangePage\0"
    "SlotExportButton\0SlotClearButton"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__RunLog[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      11,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   69,    2, 0x08 /* Private */,
       3,    0,   70,    2, 0x08 /* Private */,
       4,    0,   71,    2, 0x08 /* Private */,
       5,    0,   72,    2, 0x08 /* Private */,
       6,    0,   73,    2, 0x08 /* Private */,
       7,    0,   74,    2, 0x08 /* Private */,
       8,    0,   75,    2, 0x08 /* Private */,
       9,    0,   76,    2, 0x08 /* Private */,
      10,    0,   77,    2, 0x08 /* Private */,
      11,    0,   78,    2, 0x08 /* Private */,
      12,    0,   79,    2, 0x08 /* Private */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void UI::RunLog::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        RunLog *_t = static_cast<RunLog *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->ToTop(); break;
        case 1: _t->ToBottom(); break;
        case 2: _t->ToBack(); break;
        case 3: _t->ToNext(); break;
        case 4: _t->ChoseMinDay(); break;
        case 5: _t->ChoseMaxDay(); break;
        case 6: _t->ChangeMinDay(); break;
        case 7: _t->ChangeMaxDay(); break;
        case 8: _t->ChangePage(); break;
        case 9: _t->SlotExportButton(); break;
        case 10: _t->SlotClearButton(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObject UI::RunLog::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__RunLog.data,
      qt_meta_data_UI__RunLog,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::RunLog::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::RunLog::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__RunLog.stringdata0))
        return static_cast<void*>(const_cast< RunLog*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< RunLog*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< RunLog*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::RunLog::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 11)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 11)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 11;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
