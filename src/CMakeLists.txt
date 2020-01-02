set(pix_SRCS
    main.cpp
    pix.cpp
    db/db.cpp
    db/dbactions.cpp
    models/gallery/gallery.cpp
    models/folders/folders.cpp
    )

set(pix_HDRS
    pix.h
    db/fileloader.h
    db/db.h
    db/dbactions.h
    utils/pic.h
    utils/pic.h
    models/gallery/gallery.h
    models/folders/folders.h
    )

set(pix_ASSETS
    qml.qrc
    assets.qrc
    )

add_executable(pix
    ${pix_SRCS}
    ${pix_HDRS}
    ${pix_ASSETS}
    )

target_link_libraries(pix MauiKit Qt5::Sql Qt5::Qml Qt5::Widgets Qt5::Svg KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica)

if(ANDROID)
    target_link_libraries(pix Qt5::AndroidExtras)
    kde_source_files_enable_exceptions(pix pix.cpp)
endif()

install(TARGETS pix ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.pix.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/pix.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
