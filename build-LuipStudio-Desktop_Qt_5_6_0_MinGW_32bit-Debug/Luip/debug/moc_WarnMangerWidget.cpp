/****************************************************************************
** Meta object code from reading C++ file 'WarnMangerWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Data/WarnMangerWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'WarnMangerWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__WarnManager_t {
    QByteArrayData data[16];
    char stringdata0[192];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__WarnManager_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__WarnManager_t qt_meta_stringdata_UI__WarnManager = {
    {
QT_MOC_LITERAL(0, 0, 15), // "UI::WarnManager"
QT_MOC_LITERAL(1, 16, 18), // "UpdaterWarnSignals"
QT_MOC_LITERAL(2, 35, 0), // ""
QT_MOC_LITERAL(3, 36, 16), // "SignalAlarmClear"
QT_MOC_LITERAL(4, 53, 5), // "ToTop"
QT_MOC_LITERAL(5, 59, 8), // "ToBottom"
QT_MOC_LITERAL(6, 68, 6), // "ToBack"
QT_MOC_LITERAL(7, 75, 6), // "ToNext"
QT_MOC_LITERAL(8, 82, 16), // "SlotExportButton"
QT_MOC_LITERAL(9, 99, 15), // "SlotClearButton"
QT_MOC_LITERAL(10, 115, 11), // "ChoseMinDay"
QT_MOC_LITERAL(11, 127, 11), // "ChoseMaxDay"
QT_MOC_LITERAL(12, 139, 12), // "ChangeMinDay"
QT_MOC_LITERAL(13, 152, 12), // "ChangeMaxDay"
QT_MOC_LITERAL(14, 165, 10), // "ChangePage"
QT_MOC_LITERAL(15, 176, 15) // "UpdaterWarnSlot"

    },
    "UI::WarnManager\0UpdaterWarnSignals\0\0"
    "SignalAlarmClear\0ToTop\0ToBottom\0ToBack\0"
    "ToNext\0SlotExportButton\0SlotClearButton\0"
    "ChoseMinDay\0ChoseMaxDay\0ChangeMinDay\0"
    "ChangeMaxDay\0ChangePage\0UpdaterWarnSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__WarnManager[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      14,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   84,    2, 0x06 /* Public */,
       3,    0,   85,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       4,    0,   86,    2, 0x08 /* Private */,
       5,    0,   87,    2, 0x08 /* Private */,
       6,    0,   88,    2, 0x08 /* Private */,
       7,    0,   89,    2, 0x08 /* Private */,
       8,    0,   90,    2, 0x08 /* Private */,
       9,    0,   91,    2, 0x08 /* Private */,
      10,    0,   92,    2, 0x08 /* Private */,
      11,    0,   93,    2, 0x08 /* Private */,
      12,    0,   94,    2, 0x08 /* Private */,
      13,    0,   95,    2, 0x08 /* Private */,
      14,    0,   96,    2, 0x08 /* Private */,
      15,    0,   97,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,

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
    QMetaType::Void,

       0        // eod
};

void UI::WarnManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        WarnManager *_t = static_cast<WarnManager *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->UpdaterWarnSignals(); break;
        case 1: _t->SignalAlarmClear(); break;
        case 2: _t->ToTop(); break;
        case 3: _t->ToBottom(); break;
        case 4: _t->ToBack(); break;
        case 5: _t->ToNext(); break;
        case 6: _t->SlotExportButton(); break;
        case 7: _t->SlotClearButton(); break;
        case 8: _t->ChoseMinDay(); break;
        case 9: _t->ChoseMaxDay(); break;
        case 10: _t->ChangeMinDay(); break;
        case 11: _t->ChangeMaxDay(); break;
        case 12: _t->ChangePage(); break;
        case 13: _t->UpdaterWarnSlot(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (WarnManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WarnManager::UpdaterWarnSignals)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (WarnManager::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&WarnManager::SignalAlarmClear)) {
                *result = 1;
                return;
            }
        }
    }
    Q_UNUSED(_a);
}

const QMetaObject UI::WarnManager::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__WarnManager.data,
      qt_meta_data_UI__WarnManager,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::WarnManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::WarnManager::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__WarnManager.stringdata0))
        return static_cast<void*>(const_cast< WarnManager*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< WarnManager*>(this));
    if (!strcmp(_clname, "IAlarmNotifiable"))
        return static_cast< IAlarmNotifiable*>(const_cast< WarnManager*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< WarnManager*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::WarnManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 14)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 14;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 14)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 14;
    }
    return _id;
}

// SIGNAL 0
void UI::WarnManager::UpdaterWarnSignals()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void UI::WarnManager::SignalAlarmClear()
{
    QMetaObject::activate(this, &staticMetaObject, 1, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
