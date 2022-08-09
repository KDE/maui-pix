# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set(pix_SRCS
    main.cpp
    pix.cpp
    models/gallery/gallery.cpp
    models/folders/folders.cpp
    models/tags/tagsmodel.cpp
    models/cities/citiesmodel.cpp
    pixserver.cpp
    )

set(pix_HDRS
    pix.h
    models/gallery/gallery.h
    models/folders/folders.h
    models/tags/tagsmodel.h
    models/cities/citiesmodel.h
    )

set(pix_ASSETS
    imgs.qrc
    )

if(QUICK_COMPILER)
    qtquick_compiler_add_resources(pix_QML_QRC qml.qrc)
else()
    qt5_add_resources(pix_QML_QRC qml.qrc)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${pix_SRCS}
        ${pix_HDRS}
        ${pix_ASSETS}
        ${pix_QML_QRC}
        )
else()
    add_executable(${PROJECT_NAME}
        ${pix_SRCS}
        ${pix_HDRS}
        ${pix_ASSETS}
        ${pix_QML_QRC}
        )
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing MauiKit::ImageTools Qt5::Qml Qt5::Positioning KF5::I18n)

if(ANDROID)
    find_package(OpenSSL REQUIRED)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2 OpenSSL::SSL)
    kde_source_files_enable_exceptions(pix pix.cpp)
else()
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.pix.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
    #TODO: port to ecm_install_icons()
    install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
