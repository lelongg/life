add_definitions(-DTRANSLATION_DOMAIN=\"plasma_wallpaper_org.kde.plasma.life\")

set(lifeplugin_SRCS
    lifeplugin.cpp
)

add_library(lifeplugin SHARED ${lifeplugin_SRCS})

target_link_libraries(lifeplugin
    KF5::I18n
    Qt5::Gui
    Qt5::Qml
)
install(TARGETS lifeplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/life)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/life)
