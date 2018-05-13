QT += androidextras webview

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/


RESOURCES += \
    $$PWD/android.qrc \
    $$PWD/../kirigami-icons.qrc

RESOURCES += \
    $$PWD/../icons.qrc

DISTFILES += \
    $$PWD/src/MyService.java \
    $$PWD/src/SendIntent.java
