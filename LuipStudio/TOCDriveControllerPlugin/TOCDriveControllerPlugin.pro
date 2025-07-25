#-------------------------------------------------
#
# Project created by QtCreator 2017-04-19T17:25:01
#
#-------------------------------------------------

QT       -= gui

TARGET = TOCDriveControllerPlugin
TEMPLATE = lib
DESTDIR = ../../bin

INCLUDEPATH += ../Luip ../

INCLUDEPATH += ../Lib/log4cpp/include ../Lib/oolua/include ../Lib/lua/include

DEFINES += OOLUA_USE_EXCEPTIONS=1 OOLUA_STORE_LAST_ERROR=0

win32 {
    DEFINES += _CS_X86_WINDOWS
    DEFINES += BIL_EXPORT

Debug:LIBS   += -L$$PWD/../Lib/oolua/lib/windows/ -looluaD

    Release:LIBS += -L$$PWD/../Lib/oolua/lib/windows/ -loolua


    LIBS   += -L$$PWD/../Lib/log4cpp/lib/windows/ -llog4cpp \
              -L$$PWD/../Lib/lua/lib/windows/ -llua \
              -L$$PWD/../../bin/ -lLuaEngine \
              -L$$PWD/../../bin/ -lCommunication \
              -L$$PWD/../../bin/ -lControllerPlugin
}
unix {
     CONFIG += arm
#    CONFIG += x86

    x86 {
        DEFINES += _CS_X86_LINUX
        LIBS += -L$$PWD/../Lib/log4cpp/lib/linux-x86 -llog4cpp \
                -L$$PWD/../Lib/lua/lib/linux-x86 -llua \
                -L$$PWD/../Lib/oolua/lib/linux-x86 -loolua \
                -L$$PWD/../../bin/ -lLuaEngine \
                -L$$PWD/../../bin -lCommunication \
                -L$$PWD/../../bin/ -lControllerPlugin
    }
    arm {
        DEFINES += _CS_ARM_LINUX
        LIBS += -L$$PWD/../Lib/log4cpp/lib/linux-arm -llog4cpp \
                -L$$PWD/../Lib/lua/lib/linux-arm -llua \
                -L$$PWD/../Lib/oolua/lib/linux-arm -loolua \
                -L$$PWD/../../bin/ -lLuaEngine \
                -L$$PWD/../../bin -lCommunication \
                -L$$PWD/../../bin/ -lControllerPlugin
    }
}
android {
        CONFIG += android

        DEFINES += _CS_ARM_LINUX
        DEFINES += _CS_ANDROID
        LIBS += -L$$PWD/../Lib/log4cpp/lib/android -llog4cpp
}

SOURCES += TOCDriveControllerplugin.cpp \
    API/MeterPoints.cpp \
    API/OpticalMeterInterface.cpp \
    API/PeristalticPumpInterface.cpp \
    API/SolenoidValveInterface.cpp \
    API/ValveMap.cpp \
    TOCDriveController.cpp \
    Log.cpp \
    TOCDriveControllerPluginProxy.cpp \
    API/TemperatureControlInterface.cpp \
    API/OpticalAcquireInterface.cpp \
    API/ExtOpticalAcquireInterface.cpp \
    API/ExtTemperatureControlInterface.cpp

HEADERS += TOCDriveControllerplugin.h \
    API/Code/OpticalMeterInterface.h \
    API/Code/PeristalticPumpInterface.h \
    API/Code/SolenoidValveInterface.h \
    API/MeterPoints.h \
    API/OpticalMeterInterface.h \
    API/PeristalticPumpInterface.h \
    API/SolenoidValveInterface.h \
    API/ValveMap.h \
    Log.h \
    LuipShare.h \
    TOCDriveController.h \
    TOCDriveControllerPluginProxy.h \
    API/TemperatureControlInterface.h \
    API/Code/TemperatureControlInterface.h \
    API/Code/OpticalAcquireInterface.h \
    API/OpticalAcquireInterface.h \
    API/Code/ExtOpticalAcquireInterface.h \
    API/Code/ExtTemperatureControlInterface.h \
    API/ExtOpticalAcquireInterface.h \
    API/ExtTemperatureControlInterface.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}

