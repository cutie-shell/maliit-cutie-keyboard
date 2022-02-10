cmake_minimum_required(VERSION 3.6.0)

project(maliit-cutie-keyboard
        VERSION 0.1
        DESCRIPTION "mallit cutie keyboard")

include(FeatureSummary)
include(GNUInstallDirs)

install(FILES qml/cutie-keyboard.qml
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/maliit/plugins/)

install(DIRECTORY qml/org/cutieshell
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/maliit/plugins/org)
