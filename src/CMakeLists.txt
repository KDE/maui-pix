# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

set(pix_SRCS
    main.cpp
    pix.cpp pix.h
    models/gallery/gallery.cpp
    models/folders/folders.cpp
    models/folders/placesmodel.cpp
    models/tags/tagsmodel.cpp
    models/cities/citiesmodel.cpp
    pixserver.cpp )

set(pix_ASSETS
    imgs.qrc)

    qt_add_resources(pix_QML_QRC qml.qrc)

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${pix_SRCS}
        ${pix_ASSETS}
        ${pix_QML_QRC})
else()
    add_executable(${PROJECT_NAME}
        ${pix_SRCS}
        ${pix_ASSETS}
        ${pix_QML_QRC})
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    MauiKit4
    MauiKit4::FileBrowsing
    MauiKit4::ImageTools
    Qt6::Qml
    Qt6::Positioning
    Qt6::Concurrent
    KF6::I18n)

if(ANDROID)
    find_package(OpenSSL REQUIRED)
    target_link_libraries(${PROJECT_NAME} Qt6::AndroidExtras Qt5::QuickControls2 OpenSSL::SSL)
    kde_source_files_enable_exceptions(pix pix.cpp)
else()
    target_link_libraries(${PROJECT_NAME} Qt6::Widgets)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.pix.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    #TODO: port to ecm_install_icons()
    install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
