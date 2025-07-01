/****************************************************************************
** Meta object code from reading C++ file 'RunStatusWindow.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Home/RunStatusWindow.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'RunStatusWindow.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_RunStatusWindow_t {
    QByteArrayData data[9];
    char stringdata0[137];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_RunStatusWindow_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_RunStatusWindow_t qt_meta_stringdata_RunStatusWindow = {
    {
QT_MOC_LITERAL(0, 0, 15), // "RunStatusWindow"
QT_MOC_LITERAL(1, 16, 25), // "SignalOneKeyChangeReagent"
QT_MOC_LITERAL(2, 42, 0), // ""
QT_MOC_LITERAL(3, 43, 22), // "SignalUpdateExpectInfo"
QT_MOC_LITERAL(4, 66, 3), // "str"
QT_MOC_LITERAL(5, 70, 8), // "StopFlow"
QT_MOC_LITERAL(6, 79, 19), // "StartRangeCheckFlow"
QT_MOC_LITERAL(7, 99, 16), // "SlotOneKeyButton"
QT_MOC_LITERAL(8, 116, 20) // "SlotUpdateExpectInfo"

    },
    "RunStatusWindow\0SignalOneKeyChangeReagent\0"
    "\0SignalUpdateExpectInfo\0str\0StopFlow\0"
    "StartRangeCheckFlow\0SlotOneKeyButton\0"
    "SlotUpdateExpectInfo"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_RunStatusWindow[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   44,    2, 0x06 /* Public */,
       3,    1,   45,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       5,    0,   48,    2, 0x08 /* Private */,
       6,    0,   49,    2, 0x08 /* Private */,
       7,    0,   50,    2, 0x08 /* Private */,
       8,    1,   51,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,

       0        // eod
};

void RunStatusWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        RunStatusWindow *_t = static_cast<RunStatusWindow *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SignalOneKeyChangeReagent(); break;
        case 1: _t->SignalUpdateExpectInfo((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 2: _t->StopFlow(); break;
        case 3: _t->StartRangeCheckFlow(); break;
        case 4: _t->SlotOneKeyButton(); break;
        case 5: _t->SlotUpdateExpectInfo((*reinterpret_cast< QString(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (RunStatusWindow::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&RunStatusWindow::SignalOneKeyChangeReagent)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (RunStatusWindow::*_t)(QString );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&RunStatusWindow::SignalUpdateExpectInfo)) {
                *result = 1;
                return;
            }
        }
    }
}

const QMetaObject RunStatusWindow::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_RunStatusWindow.data,
      qt_meta_data_RunStatusWindow,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *RunStatusWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *RunStatusWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_RunStatusWindow.stringdata0))
        return static_cast<void*>(const_cast< RunStatusWindow*>(this));
    if (!strcmp(_clname, "IScheduleNotifiable"))
        return static_cast< IScheduleNotifiable*>(const_cast< RunStatusWindow*>(this));
    if (!strcmp(_clname, "Result::IResultNotifiable"))
        return static_cast< Result::IResultNotifiable*>(const_cast< RunStatusWindow*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< RunStatusWindow*>(this));
    if (!strcmp(_clname, "IStatusNotifiable"))
        return static_cast< IStatusNotifiable*>(const_cast< RunStatusWindow*>(this));
    if (!strcmp(_clname, "IUpdateWidgetNotifiable"))
        return static_cast< IUpdateWidgetNotifiable*>(const_cast< RunStatusWindow*>(this));
    return QWidget::qt_metacast(_clname);
}

int RunStatusWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 6)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void RunStatusWindow::SignalOneKeyChangeReagent()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}

// SIGNAL 1
void RunStatusWindow::SignalUpdateExpectInfo(QString _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_END_MOC_NAMESPACE
