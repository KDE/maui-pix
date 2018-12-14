project(pix)
cmake_minimum_required(VERSION 3.0)

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(MauiKit REQUIRED)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Widgets)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(FeatureSummary)
include(ECMAddAppIcon)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)

set(pix_SRCS
    main.cpp
    src/pix.cpp
    src/db/db.cpp
    src/db/dbactions.cpp
    src/models/basemodel.cpp
    src/models/baselist.cpp
    src/models/gallery/gallery.cpp
    src/models/albums/albums.cpp
    src/models/folders/folders.cpp
    src/models/folders/foldermodel.cpp
    src/models/cloud/cloud.cpp
    )

set(pix_HDRS
    src/pix.h
    src/db/fileloader.h
    src/db/db.h
    src/db/dbactions.h
    src/utils/pic.h
    src/models/basemodel.h
    src/models/baselist.h
    src/models/gallery/gallery.h
    src/models/albums/albums.h
    src/models/folders/folders.h
    src/models/folders/foldermodel.h
    src/models/cloud/cloud.h
    )

set(pix_ASSETS
    src/qml.qrc
    assets.qrc
    )

add_executable(pix
    ${pix_SRCS}
    ${pix_HDRS}
    ${pix_ASSETS}
    )

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)

    target_link_libraries(vvave Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(pix src/pix.cpp)
else() 
    find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica)
    find_package(Qt5 REQUIRED COMPONENTS WebEngine)

    target_link_libraries(pix KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica)
endif()

if (TARGET create-apk-pix)
    set_target_properties(create-apk-pix PROPERTIES ANDROID_APK_DIR "${MAUIKIT_ANDROID_DIR}")
endif()

target_link_libraries(pix MauiKit Qt5::Sql Qt5::Qml Qt5::Widgets Qt5::Svg)

install(TARGETS pix ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.pix.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
install(FILES org.kde.pix.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL   FATAL_ON_MISSING_REQUIRED_PACKAGES)
