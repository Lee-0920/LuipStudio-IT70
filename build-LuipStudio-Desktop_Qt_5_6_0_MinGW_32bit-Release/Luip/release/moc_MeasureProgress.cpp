/****************************************************************************
** Meta object code from reading C++ file 'MeasureProgress.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.6.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../LuipStudio/Luip/UI/Frame/MeasureProgress.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'MeasureProgress.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.6.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
struct qt_meta_stringdata_UI__MeasureProgress_t {
    QByteArrayData data[13];
    char stringdata0[190];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_UI__MeasureProgress_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_UI__MeasureProgress_t qt_meta_stringdata_UI__MeasureProgress = {
    {
QT_MOC_LITERAL(0, 0, 19), // "UI::MeasureProgress"
QT_MOC_LITERAL(1, 20, 16), // "UpdateInfoSignal"
QT_MOC_LITERAL(2, 37, 0), // ""
QT_MOC_LITERAL(3, 38, 5), // "title"
QT_MOC_LITERAL(4, 44, 4), // "time"
QT_MOC_LITERAL(5, 49, 18), // "SetDelayTimeSignal"
QT_MOC_LITERAL(6, 68, 14), // "UpdateProgress"
QT_MOC_LITERAL(7, 83, 22), // "BlockingUpdateProgress"
QT_MOC_LITERAL(8, 106, 16), // "StartTimerSignal"
QT_MOC_LITERAL(9, 123, 15), // "StopTimerSignal"
QT_MOC_LITERAL(10, 139, 14), // "SlotUpdateInfo"
QT_MOC_LITERAL(11, 154, 18), // "slotUpdataDateTime"
QT_MOC_LITERAL(12, 173, 16) // "SetDelayTimeSlot"

    },
    "UI::MeasureProgress\0UpdateInfoSignal\0"
    "\0title\0time\0SetDelayTimeSignal\0"
    "UpdateProgress\0BlockingUpdateProgress\0"
    "StartTimerSignal\0StopTimerSignal\0"
    "SlotUpdateInfo\0slotUpdataDateTime\0"
    "SetDelayTimeSlot"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_UI__MeasureProgress[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       6,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    2,   59,    2, 0x06 /* Public */,
       5,    1,   64,    2, 0x06 /* Public */,
       6,    0,   67,    2, 0x06 /* Public */,
       7,    0,   68,    2, 0x06 /* Public */,
       8,    0,   69,    2, 0x06 /* Public */,
       9,    0,   70,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
      10,    2,   71,    2, 0x0a /* Public */,
      11,    0,   76,    2, 0x0a /* Public */,
      12,    1,   77,    2, 0x0a /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::QString, QMetaType::Int,    3,    4,
    QMetaType::Void, QMetaType::Int,    4,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void, QMetaType::QString, QMetaType::Int,    3,    4,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    4,

       0        // eod
};

void UI::MeasureProgress::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        MeasureProgress *_t = static_cast<MeasureProgress *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->UpdateInfoSignal((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2]))); break;
        case 1: _t->SetDelayTimeSignal((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 2: _t->UpdateProgress(); break;
        case 3: _t->BlockingUpdateProgress(); break;
        case 4: _t->StartTimerSignal(); break;
        case 5: _t->StopTimerSignal(); break;
        case 6: _t->SlotUpdateInfo((*reinterpret_cast< QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2]))); break;
        case 7: _t->slotUpdataDateTime(); break;
        case 8: _t->SetDelayTimeSlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        void **func = reinterpret_cast<void **>(_a[1]);
        {
            typedef void (MeasureProgress::*_t)(QString , int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureProgress::UpdateInfoSignal)) {
                *result = 0;
                return;
            }
        }
        {
            typedef void (MeasureProgress::*_t)(int );
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureProgress::SetDelayTimeSignal)) {
                *result = 1;
                return;
            }
        }
        {
            typedef void (MeasureProgress::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureProgress::UpdateProgress)) {
                *result = 2;
                return;
            }
        }
        {
            typedef void (MeasureProgress::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureProgress::BlockingUpdateProgress)) {
                *result = 3;
                return;
            }
        }
        {
            typedef void (MeasureProgress::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureProgress::StartTimerSignal)) {
                *result = 4;
                return;
            }
        }
        {
            typedef void (MeasureProgress::*_t)();
            if (*reinterpret_cast<_t *>(func) == static_cast<_t>(&MeasureProgress::StopTimerSignal)) {
                *result = 5;
                return;
            }
        }
    }
}

const QMetaObject UI::MeasureProgress::staticMetaObject = {
    { &QProgressBar::staticMetaObject, qt_meta_stringdata_UI__MeasureProgress.data,
      qt_meta_data_UI__MeasureProgress,  qt_static_metacall, Q_NULLPTR, Q_NULLPTR}
};


const QMetaObject *UI::MeasureProgress::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *UI::MeasureProgress::qt_metacast(const char *_clname)
{
    if (!_clname) return Q_NULLPTR;
    if (!strcmp(_clname, qt_meta_stringdata_UI__MeasureProgress.stringdata0))
        return static_cast<void*>(const_cast< MeasureProgress*>(this));
    return QProgressBar::qt_metacast(_clname);
}

int UI::MeasureProgress::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QProgressBar::qt_metacall(_c, _id, _a);
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
void UI::MeasureProgress::UpdateInfoSignal(QString _t1, int _t2)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)), const_cast<void*>(reinterpret_cast<const void*>(&_t2)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void UI::MeasureProgress::SetDelayTimeSignal(int _t1)
{
    void *_a[] = { Q_NULLPTR, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void UI::MeasureProgress::UpdateProgress()
{
    QMetaObject::activate(this, &staticMetaObject, 2, Q_NULLPTR);
}

// SIGNAL 3
void UI::MeasureProgress::BlockingUpdateProgress()
{
    QMetaObject::activate(this, &staticMetaObject, 3, Q_NULLPTR);
}

// SIGNAL 4
void UI::MeasureProgress::StartTimerSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 4, Q_NULLPTR);
}

// SIGNAL 5
void UI::MeasureProgress::StopTimerSignal()
{
    QMetaObject::activate(this, &staticMetaObject, 5, Q_NULLPTR);
}
QT_END_MOC_NAMESPACE
