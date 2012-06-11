/*
 * This file is part of Maliit plugins
 *
 * Copyright (C) 2012 John Brooks <john.brooks@dereferenced.net>
 * Copyright (C) Jakub Pavelek <jpavelek@live.com>
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list
 * of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list
 * of conditions and the following disclaimer in the documentation and/or other materials
 * provided with the distribution.
 * Neither the name of Nokia Corporation nor the names of its contributors may be
 * used to endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

import QtQuick 2.0
import "KeyboardUiConstants.js" as UI
import com.meego.maliitquick 1.0

MouseArea {
    id: keyboardBase

    property Item layout
    property Item pressedKey

    onLayoutChanged: if (layout) layout.parent = keyboardBase

    Rectangle {
        id: background
        anchors.fill: parent
        color: UI.BG_COLOR
    }

    Popper {
        id: popper
        z: 10
        target: pressedKey
    }
    Timer {
        id: pressTimer
        interval: 500
    }
    Timer {
        id: autorepeatTimer
        repeat: true
        onTriggered: {
            interval = 80
            if (pressedKey != null) {
                handleKeyClick()
            } else {
                stop()
            }
        }
    }

    Connections {
        target: MInputMethodQuick
        onCursorPositionChanged: {
            applyAutocaps()
        }
        onFocusTargetChanged: {
            if (activeEditor) {
                resetKeyboard()
                applyAutocaps()
            }
        }
    }

    /* Mouse handling */
    property int _startX
    property int _startY

    onPressed: {
        _startX = mouse.x
        _startY = mouse.y
        pressTimer.start()
        updatePressedKey(mouse.x, mouse.y)
    }

    onPositionChanged: {
        // Hide keyboard on flick down
        if (pressTimer.running && (mouse.y - _startY > (height * 0.3))) {
            MInputMethodQuick.userHide()
            if (pressedKey != null)
		    pressedKey.pressed = false
            pressedKey = null
            autorepeatTimer.stop()
            return
        }

        updatePressedKey(mouse.x, mouse.y);
    }

    onReleased: {
        autorepeatTimer.stop()

        if (pressedKey === null)
            return

        handleKeyClick()
        pressedKey.pressed = false
        pressedKey = null
    }

    function handleKeyClick() {
        var resetShift = !layout.isShiftLocked

        if (pressedKey.key === Qt.Key_Shift) {
            resetShift = false
        }

        if (pressedKey.text.length) {
            MInputMethodQuick.sendCommit(pressedKey.text)
        } else if (pressedKey.key === Qt.Key_Return) {
            MInputMethodQuick.activateActionKey()
        } else if (pressedKey.key === Qt.Key_Backspace) {
            if (MInputMethodQuick.surroundingTextValid && MInputMethodQuick.cursorPosition == 0) {
                resetShift = false
            }

            MInputMethodQuick.sendCommit("\b")
        } else  {
            resetShift = false
        }

        if (resetShift)
            layout.isShifted = false

        pressedKey.clicked()
    }

    function updatePressedKey(x, y) {
        var key = keyAt(x, y)
        if (pressedKey === key)
            return;

        autorepeatTimer.stop()
        if (pressedKey !== null)
            pressedKey.pressed = false

        pressedKey = key

        if (pressedKey !== null) {
            pressedKey.pressed = true
            if (pressedKey.repeat) {
                autorepeatTimer.interval = 800
                autorepeatTimer.start()
            }
        }
    }

    function keyAt(x, y) {
        var item = layout;
        x -= layout.x;
        y -= layout.y;

        while ((item = item.childAt(x, y)) != null) {
            if (typeof item.text !== 'undefined' && typeof item.pressed !== 'undefined') {
                return item;
            }

            // Cheaper mapToItem, assuming we're not using anything fancy.
            x -= item.x;
            y -= item.y;
        }

        return null;
    }

    function resetKeyboard() {
        if (!layout)
            return
        layout.isShifted = false
        layout.isShiftLocked = false
        layout.inSymView = false
        layout.inSymView2 = false
    }

    function applyAutocaps() {
        if (MInputMethodQuick.surroundingTextValid
                && MInputMethodQuick.contentType === Maliit.FreeTextContentType
                && !MInputMethodQuick.hiddenText
                && layout && layout.isShiftLocked === false) {
            var position = MInputMethodQuick.cursorPosition
            var text = MInputMethodQuick.surroundingText.substring(0, position)

            if (position == 0
                    || (position == 1 && text[0] === " ")
                    || (position >= 2 && text[position - 1] === " "
                        && ".?!".indexOf(text[position - 2]) >= 0)) {
                layout.isShifted = true
            } else {
                layout.isShifted = false
            }
        }
    }
}
 