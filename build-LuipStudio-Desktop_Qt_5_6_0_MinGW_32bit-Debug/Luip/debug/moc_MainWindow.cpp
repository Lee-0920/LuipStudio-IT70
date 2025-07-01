/****************************************************************************
** Meta object code from reading C++ file 'MainWindow.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Frame/MainWindow.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'MainWindow.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__MainWindow_t {
    QByteArrayData data[11];
    char stringdata0[156];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__MainWindow_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__MainWindow_t qt_meta_stringdata_UI__MainWindow = {
    {
QT_MOC_LITERAL(0, 0, 14), // "UI::MainWindow"
QT_MOC_LITERAL(1, 15, 12), // "remoteUpdate"
QT_MOC_LITERAL(2, 28, 0), // ""
QT_MOC_LITERAL(3, 29, 10), // "ShowWidget"
QT_MOC_LITERAL(4, 40, 16), // "SetupTitleWidget"
QT_MOC_LITERAL(5, 57, 13), // "SetupUIWidget"
QT_MOC_LITERAL(6, 71, 12), // "SlotTurnPage"
QT_MOC_LITERAL(7, 84, 11), // "currentPage"
QT_MOC_LITERAL(8, 96, 23), // "SlotChangeUserInterface"
QT_MOC_LITERAL(9, 120, 22), // "SlotUpdaterSignalTimer"
QT_MOC_LITERAL(10, 143, 12) // "ScreenUpdate"

    },
    "UI::MainWindow\0remoteUpdate\0\0ShowWidget\0"
    "SetupTitleWidget\0SetupUIWidget\0"
    "SlotTurnPage\0currentPage\0"
    "SlotChangeUserInterface\0SlotUpdaterSignalTimer\0"
    "ScreenUpdate"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__MainWindow[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       8,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   54,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       3,    0,   55,    2, 0x0a /* Public */,
       4,    0,   56,    2, 0x08 /* Private */,
       5,    0,   57,    2, 0x08 /* Private */,
       6,    1,   58,    2, 0x08 /* Private */,
       8,    0,   61,    2, 0x08 /* Private */,
       9,    0,   62,    2, 0x08 /* Private */,
      10,    0,   63,    2, 0x08 /* Private */,

 // signals: parameters
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    7,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void UI::MainWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        MainWindow *_t = static_cast<MainWindow *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->remoteUpdate(); break;
        case 1: _t->ShowWidget(); break;
        case 2: _t->SetupTitleWidget(); break;
        case 3: _t->SetupUIWidget(); break;
        case 4: _t->SlotTurnPage((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 5: _t->SlotChangeUserInterface(); break;
        case 6: _t->SlotUpdaterSignalTimer(); break;
        case 7: _t->ScreenUpdate(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (MainWindow::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MainWindow::remoteUpdate)) {
                *result = 0;
                return;
            }
        }
    }
}

const QMetaObject UI::MainWindow::staticMetaObject = {
    { &DropShadowWidget::staticMetaObject, qt_meta_stringdata_UI__MainWindow.data,
      qt_meta_data_UI__MainWindow,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::MainWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::MainWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__MainWindow.stringdata0))
        return static_cast<void*>(const_cast< MainWindow*>(this));
    return DropShadowWidget::qt_metacast(_clname);
}

int UI::MainWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = DropShadowWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 8)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 8;
    }
    return _id;
}

// SIGNAL 0
void UI::MainWindow::remoteUpdate()
{
    QMetaObject::activate(this, &staticMetaObject, 0, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
