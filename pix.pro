QT *= qml \
    quick \
    sql

TARGET = pix
TEMPLATE = app

CONFIG += ordered
CONFIG += c++17

linux:unix:!android {

    message(Building for Linux KDE)
    QT += KService KNotifications KNotifications KI18n
    QT += KIOCore KIOFileWidgets KIOWidgets KNTLM
    LIBS += -lMauiKit

} else:android {

    message(Building helpers for Android)   
    QMAKE_LINK += -nostdlib++
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android_files

    DEFINES *= \
        COMPONENT_FM \
        COMPONENT_TAGGING \
        MAUIKIT_STYLE \
        ANDROID_OPENSSL

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += src/main.cpp \
    src/pix.cpp \
    src/db/db.cpp \
    src/db/dbactions.cpp \
    src/models/gallery/gallery.cpp \
    src/models/folders/folders.cpp \

HEADERS += \
    src/pix.h \
    src/db/fileloader.h \
    src/db/db.h \
    src/db/dbactions.h \
    src/utils/pic.h \
    src/models/gallery/gallery.h \
    src/models/folders/folders.h \

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    src/qml.qrc \
    src/assets.qrc

INCLUDEPATH += src/

include(install.pri)

