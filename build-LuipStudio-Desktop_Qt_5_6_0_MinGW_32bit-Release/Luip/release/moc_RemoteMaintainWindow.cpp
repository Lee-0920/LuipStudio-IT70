/****************************************************************************
** Meta object code from reading C++ file 'RemoteMaintainWindow.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Maintain/RemoteMaintainWindow.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'RemoteMaintainWindow.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__RemoteMainTainWindow_t {
    QByteArrayData data[5];
    char stringdata0[76];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__RemoteMainTainWindow_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__RemoteMainTainWindow_t qt_meta_stringdata_UI__RemoteMainTainWindow = {
    {
QT_MOC_LITERAL(0, 0, 24), // "UI::RemoteMainTainWindow"
QT_MOC_LITERAL(1, 25, 31), // "SignalOneKeyChangeReagentWindow"
QT_MOC_LITERAL(2, 57, 0), // ""
QT_MOC_LITERAL(3, 58, 11), // "itemClicked"
QT_MOC_LITERAL(4, 70, 5) // "index"

    },
    "UI::RemoteMainTainWindow\0"
    "SignalOneKeyChangeReagentWindow\0\0"
    "itemClicked\0index"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__RemoteMainTainWindow[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   24,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       3,    1,   25,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void, QMetaType::QModelIndex,    4,

       0        // eod
};

void UI::RemoteMainTainWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        RemoteMainTainWindow *_t = static_cast<RemoteMainTainWindow *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->SignalOneKeyChangeReagentWindow(); break;
        case 1: _t->itemClicked((*reinterpret_cast< QModelIndex(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (RemoteMainTainWindow::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&RemoteMainTainWindow::SignalOneKeyChangeReagentWindow)) {
                *result = 0;
                return;
            }
        }
    }
}

const QMetaObject UI::RemoteMainTainWindow::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_UI__RemoteMainTainWindow.data,
      qt_meta_data_UI__RemoteMainTainWindow,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::RemoteMainTainWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::RemoteMainTainWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__RemoteMainTainWindow.stringdata0))
        return static_cast<void*>(const_cast< RemoteMainTainWindow*>(this));
    if (!strcmp(_clname, "IUserChangeNotifiable"))
        return static_cast< IUserChangeNotifiable*>(const_cast< RemoteMainTainWindow*>(this));
    return QWidget::qt_metacast(_clname);
}

int UI::RemoteMainTainWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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

// SIGNAL 0
void UI::RemoteMainTainWindow::SignalOneKeyChangeReagentWindow()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
