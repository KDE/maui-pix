# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later


set(pix_SRCS
    main.cpp
    pix.cpp
    models/gallery/gallery.cpp
    models/folders/folders.cpp
    models/picinfomodel.cpp
    utils/picinfo/exiv2extractor.cpp
    utils/picinfo/reversegeocoder.cpp
    utils/picinfo/kdtree.c
    )

set(pix_HDRS
    pix.h
    db/fileloader.h
    utils/pic.h
    models/gallery/gallery.h
    models/folders/folders.h
    models/picinfomodel.h
    utils/picinfo/exiv2extractor.h
    utils/picinfo/reversegeocoder.h
    utils/picinfo/kdtree.h
    )

set(pix_ASSETS
    qml.qrc
    imgs.qrc
    )

add_executable(pix
    ${pix_SRCS}
    ${pix_HDRS}
    ${pix_ASSETS}
    )

target_link_libraries(pix MauiKit Qt5::Sql Qt5::Qml Qt5::Svg Qt5::Positioning KF5::I18n LibExiv2::LibExiv2)

if(ANDROID)
    target_link_libraries(pix Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(pix pix.cpp)
endif()

install(TARGETS pix ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.pix.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)

#
# Reverse GeoLookup Data
#
# Packagers can download the file and put it in the tarball
if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/cities1000.zip)
    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/cities1000.zip DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endif()

if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/cities1000.zip)
    file (DOWNLOAD "http://download.geonames.org/export/dump/cities1000.zip"
                ${CMAKE_CURRENT_BINARY_DIR}/cities1000.zip
        SHOW_PROGRESS
    )
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar -xzf ${CMAKE_CURRENT_BINARY_DIR}/cities1000.zip
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/admin1CodesASCII.txt)
    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/admin1CodesASCII.txt DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endif()

if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/admin1CodesASCII.txt)
    file (DOWNLOAD "http://download.geonames.org/export/dump/admin1CodesASCII.txt"
                ${CMAKE_CURRENT_BINARY_DIR}/admin1CodesASCII.txt
        SHOW_PROGRESS
    )
endif()
file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/admin1CodesASCII.txt ${CMAKE_CURRENT_BINARY_DIR}/admin1Codes.txt)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/admin2Codes.txt)
    file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/admin2Codes.txt DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endif()

if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/admin2Codes.txt)
    file (DOWNLOAD "http://download.geonames.org/export/dump/admin2Codes.txt"
                ${CMAKE_CURRENT_BINARY_DIR}/admin2Codes.txt
        SHOW_PROGRESS
    )
endif()

install (FILES ${CMAKE_CURRENT_BINARY_DIR}/cities1000.txt DESTINATION ${DATA_INSTALL_DIR}/koko)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/admin1Codes.txt DESTINATION ${DATA_INSTALL_DIR}/koko)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/admin2Codes.txt DESTINATION ${DATA_INSTALL_DIR}/koko)
install (FILES countries.csv DESTINATION ${DATA_INSTALL_DIR}/koko)
