CONFIG += ordered
TEMPLATE = subdirs
SUBDIRS = \
          ut_widgetbar \
          ut_mvirtualkeyboard \
          ut_mkeyboardhost \
          ut_mkeyboardplugin \
          ut_mimcorrectioncandidatewidget \
          ut_keybutton \
          ut_keybuttonarea \
          ut_symbolview \
          ut_notification \
          ut_limitedtimer \
          ut_vkbdatakey \
          ut_horizontalswitcher \
          ut_layoutsmanager \
          ut_mimtoolbar \
          ut_mhardwarekeyboard \
          ut_hwkbcharloopsmanager \
          bm_keybuttonarea \
          bm_symbols \
          ft_mxkb \

target.commands += $$system(touch tests.xml)
target.path = /usr/share/meego-keyboard-tests
target.files += qtestlib2junitxml.xsl runtests.sh tests.xml
INSTALLS += target

QMAKE_EXTRA_TARGETS += check-xml
check-xml.target = check-xml
check-xml.CONFIG = recursive

QMAKE_EXTRA_TARGETS += check
check.target = check
check.CONFIG = recursive
