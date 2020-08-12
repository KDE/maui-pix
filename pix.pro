# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


QT *= qml \
    quick \
    svg

CONFIG += ordered
CONFIG += c++17

TARGET = pix
TEMPLATE = app

VERSION_MAJOR = 1
VERSION_MINOR = 2
VERSION_BUILD = 0

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}

DEFINES += PIX_VERSION_STRING=\\\"$$VERSION\\\"

linux:unix:!android {

    message(Building for Linux KDE)
    QT += KService KNotifications KNotifications KI18n
    QT += KIOCore KIOFileWidgets KIOWidgets KNTLM
    LIBS += -lMauiKit

} else {

    android {
        message(Building for Android)
        QMAKE_LINK += -nostdlib++
        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android_files
        DISTFILES += $$PWD/android_files/AndroidManifest.xml
        DEFINES *= ANDROID_OPENSSL
     }

    DEFINES *= \
        COMPONENT_FM \
        COMPONENT_TAGGING \
        MAUIKIT_STYLE

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)

    DEFINES += STATIC_KIRIGAMI
    win32 {
        RC_ICONS = $$PWD/windows_files/pix.ico
    }
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
#    src/db/dbactions.cpp \
    src/models/gallery/gallery.cpp \
    src/models/folders/folders.cpp

HEADERS += \
    src/pix.h \
    src/db/fileloader.h \
#    src/db/dbactions.h \
    src/utils/pic.h \
    src/models/gallery/gallery.h \
    src/models/folders/folders.h

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    $$PWD/src/qml.qrc \
    $$PWD/src/imgs.qrc

INCLUDEPATH += src/

include(install.pri)

