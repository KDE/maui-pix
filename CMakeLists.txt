project(pix)
cmake_minimum_required(VERSION 3.0)

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(MauiKit REQUIRED)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql QuickControls2 Widgets)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(FeatureSummary)
include(ECMAddAppIcon)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)

add_executable(pix
    assests.qrc
    main.cpp
    src/pix.cpp
    src/qml.qrc
    db/db.cpp
    dbactions.cpp    
    )
    
if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)

    target_link_libraries(vvave Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(pix src/pix.cpp)
endif()

if (TARGET create-apk-pix)
    set_target_properties(create-apk-pix PROPERTIES ANDROID_APK_DIR "${MAUIKIT_ANDROID_DIR}")
endif()

target_link_libraries(pix Qt5::Sql Qt5::Qml Qt5::Widgets)

install(TARGETS pix ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.pix.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
install(FILES org.kde.pix.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL   FATAL_ON_MISSING_REQUIRED_PACKAGES)
