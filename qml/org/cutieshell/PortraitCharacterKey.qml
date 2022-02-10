import QtQuick 2.6
import "KeyboardUiConstants.js" as UI

CharacterKey {
    width: keyArea.width / 10
    height: keyArea.height / 4

    topPadding: dpi.value
    bottomPadding: topPadding
    leftPadding: dpi.value/2
    rightPadding: leftPadding
}
