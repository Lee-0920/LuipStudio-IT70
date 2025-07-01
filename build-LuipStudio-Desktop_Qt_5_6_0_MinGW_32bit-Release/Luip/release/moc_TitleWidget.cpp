/****************************************************************************
** Meta object code from reading C++ file 'TitleWidget.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Frame/TitleWidget.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'TitleWidget.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__TitleWidget_t {
    QByteArrayData data[16];
    char stringdata0[215];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__TitleWidget_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__TitleWidget_t qt_meta_stringdata_UI__TitleWidget = {
    {
QT_MOC_LITERAL(0, 0, 15), // "UI::TitleWidget"
QT_MOC_LITERAL(1, 16, 8), // "TurnPage"
QT_MOC_LITERAL(2, 25, 0), // ""
QT_MOC_LITERAL(3, 26, 11), // "currentPage"
QT_MOC_LITERAL(4, 38, 16), // "CreatContextMenu"
QT_MOC_LITERAL(5, 55, 19), // "ChangeUserInterface"
QT_MOC_LITERAL(6, 75, 17), // "ScreenAlreadyLock"
QT_MOC_LITERAL(7, 93, 7), // "ShowMin"
QT_MOC_LITERAL(8, 101, 11), // "CloseWidget"
QT_MOC_LITERAL(9, 113, 12), // "SlotTurnPage"
QT_MOC_LITERAL(10, 126, 20), // "SlotCreatContextMenu"
QT_MOC_LITERAL(11, 147, 17), // "slotMenuTriggered"
QT_MOC_LITERAL(12, 165, 8), // "QAction*"
QT_MOC_LITERAL(13, 174, 6), // "action"
QT_MOC_LITERAL(14, 181, 20), // "slotUserCancellation"
QT_MOC_LITERAL(15, 202, 12) // "SlotTimerout"

    },
    "UI::TitleWidget\0TurnPage\0\0currentPage\0"
    "CreatContextMenu\0ChangeUserInterface\0"
    "ScreenAlreadyLock\0ShowMin\0CloseWidget\0"
    "SlotTurnPage\0SlotCreatContextMenu\0"
    "slotMenuTriggered\0QAction*\0action\0"
    "slotUserCancellation\0SlotTimerout"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__TitleWidget[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
      11,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       6,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    1,   69,    2, 0x06 /* Public */,
       4,    0,   72,    2, 0x06 /* Public */,
       5,    0,   73,    2, 0x06 /* Public */,
       6,    0,   74,    2, 0x06 /* Public */,
       7,    0,   75,    2, 0x06 /* Public */,
       8,    0,   76,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       9,    1,   77,    2, 0x0a /* Public */,
      10,    0,   80,    2, 0x0a /* Public */,
      11,    1,   81,    2, 0x0a /* Public */,
      14,    0,   84,    2, 0x0a /* Public */,
      15,    0,   85,    2, 0x0a /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::Int,    3,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void, QMetaType::QString,    3,
    QMetaType::Void,
    QMetaType::Void, 0x80000000 | 12,   13,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void UI::TitleWidget::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        TitleWidget *_t = static_cast<TitleWidget *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->TurnPage((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->CreatContextMenu(); break;
        case 2: _t->ChangeUserInterface(); break;
        case 3: _t->ScreenAlreadyLock(); break;
        case 4: _t->ShowMin(); break;
        case 5: _t->CloseWidget(); break;
        case 6: _t->SlotTurnPage((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 7: _t->SlotCreatContextMenu(); break;
        case 8: _t->slotMenuTriggered((*reinterpret_cast< QAction*(*)>(_a[1]))); break;
        case 9: _t->slotUserCancellation(); break;
        case 10: _t->SlotTimerout(); break;
        default: ;
        }
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 8:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<int*>(_a[0]) = -1; break;
            case 0:
                *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QAction* >(); break;
            }
            break;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (TitleWidget::*_t)(int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TitleWidget::TurnPage)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (TitleWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TitleWidget::CreatContextMenu)) {
                *result = 1;
                return;
            }
        }
        {
            typedef void (TitleWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TitleWidget::ChangeUserInterface)) {
                *result = 2;
                return;
            }
        }
        {
            typedef void (TitleWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TitleWidget::ScreenAlreadyLock)) {
                *result = 3;
                return;
            }
        }
        {
            typedef void (TitleWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TitleWidget::ShowMin)) {
                *result = 4;
                return;
            }
        }
        {
            typedef void (TitleWidget::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&TitleWidget::CloseWidget)) {
                *result = 5;
                return;
            }
        }
    }
}

const QMetaObject UI::TitleWidget::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__TitleWidget.data,
      qt_meta_data_UI__TitleWidget,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::TitleWidget::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::TitleWidget::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__TitleWidget.stringdata0))
        return static_cast<void*>(const_cast< TitleWidget*>(this));
    if (!strcmp(_clname, "ILockScreenNotifiable"))
        return static_cast< ILockScreenNotifiable*>(const_cast< TitleWidget*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::TitleWidget::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
            qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    }
    return _id;
}

// SIGNAL 0
void UI::TitleWidget::TurnPage(int _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void UI::TitleWidget::CreatContextMenu()
{
    QMetaObject::activate(this, &staticMetaObject, 1, Q_NULLPTR);
}

// SIGNAL 2
void UI::TitleWidget::ChangeUserInterface()
{
    QMetaObject::activate(this, &staticMetaObject, 2, Q_NULLPTR);
}

// SIGNAL 3
void UI::TitleWidget::ScreenAlreadyLock()
{
    QMetaObject::activate(this, &staticMetaObject, 3, Q_NULLPTR);
}

// SIGNAL 4
void UI::TitleWidget::ShowMin()
{
    QMetaObject::activate(this, &staticMetaObject, 4, Q_NULLPTR);
}

// SIGNAL 5
void UI::TitleWidget::CloseWidget()
{
    QMetaObject::activate(this, &staticMetaObject, 5, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
