# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


cmake_minimum_required(VERSION 3.0)
set(PIX_VERSION 1.2.0)
project(pix VERSION ${PIX_VERSION})

set(REQUIRED_QT_VERSION 5.10.0)
set(REQUIRED_KF5_VERSION 5.60)

find_package(ECM ${REQUIRED_KF5_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})
set(CMAKE_CXX_STANDARD 17)

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Positioning)
find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica)
find_package(MauiKit REQUIRED)
find_package(LibExiv2 0.21 REQUIRED)

include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(ECMSetupVersion)
include(FeatureSummary)

ecm_setup_version(${PIX_VERSION}
    VARIABLE_PREFIX PIX
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/pix_version.h"
    )

if (ANDROID)
    find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED COMPONENTS AndroidExtras)
endif()

kde_enable_exceptions()

add_subdirectory(src)

install(FILES org.kde.pix.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
