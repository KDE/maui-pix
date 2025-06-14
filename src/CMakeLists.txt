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
    # models/thumbnailer.cpp
    pixserver.cpp )

if(UNIX AND NOT ANDROID)
    qt_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/pixserver.h org.kde.Pix.xml)
    qt_add_dbus_adaptor(pix_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Pix.xml pixserver.h Server)
    qt_add_dbus_interface(pix_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Pix.xml pixinterface)
endif()

qt_add_resources(pix_ASSETS imgs.qrc)

if(ANDROID)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${pix_SRCS}
        ${pix_ASSETS})

    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android_files/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)

else()
    qt_add_executable(${PROJECT_NAME}
    MANUAL_FINALIZATION
        ${pix_SRCS}
        ${pix_dbus_SRCS}
        ${pix_ASSETS})
endif()

set_source_files_properties(widgets/views/Viewer/Viewer.js PROPERTIES
    QT_QML_SKIP_QMLDIR_ENTRY TRUE)

qt_add_qml_module(${PROJECT_NAME} URI app.maui.pix
    NO_PLUGIN
    QML_FILES
    main.qml
    view_models/PixGrid.qml
    view_models/PixPic.qml
    widgets/views/Folders/FoldersView.qml
    widgets/views/Gallery/GalleryView.qml
    widgets/views/Tags/TagsView.qml
    widgets/views/Viewer/PixViewer.qml
    widgets/views/Viewer/OCROverlay.qml
    widgets/views/Viewer/Viewer.qml
    widgets/views/Viewer/Viewer.js
    widgets/views/Viewer/GalleryRoll.qml
    widgets/views/Tags/TagsSidebar.qml
    view_models/PixMenu.qml
    widgets/SelectionBar.qml
    widgets/views/Cloud/CloudView.qml
    view_models/PixPicList.qml
    widgets/SettingsDialog.qml
    widgets/OCRSettingsPage.qml
    widgets/Sidebar.qml
    widgets/AppView.qml
    widgets/views/Viewer/OCRPage.qml
    widgets/views/CollectionView.qml
    widgets/views/FloatingViewer.qml)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::FileBrowsing
    MauiKit4::ImageTools
    Qt6::Core
    Qt6::Qml
    Qt6::Positioning
    Qt6::Concurrent
    KF6::I18n)

if(ANDROID)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::Sql
        Qt6::Multimedia
        Qt6::QuickControls2)
    kde_source_files_enable_exceptions(pix pix.cpp)
else()
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::Quick
        Qt6::Widgets
        KF6::KIOCore
        KF6::KIOWidgets)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.pix.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    #TODO: port to ecm_install_icons()
    install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

qt_finalize_target(${PROJECT_NAME})

