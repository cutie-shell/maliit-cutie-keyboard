/*
 * This file is part of Maliit plugins
 *
 * Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies). All rights reserved.
 *
 * Contact: Jakub Pavelek <jpavelek@live.com>
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

import QtQuick 2.6
import "KeyboardUiConstants.js" as UI
import QtGraphicalEffects 1.15

KeyBase {
    id: aFunctKey

    property string icon
    property string caption
    property int sourceWidth: -1
    property int sourceHeight: -1

    topPadding: dpi.value
    bottomPadding: topPadding
    leftPadding: dpi.value/2
    rightPadding: leftPadding

    showPopper: false

    Rectangle {
        color: (themeVariantConfig.value == "dark") ? "#60000000" : "#6fffffff"
        anchors.fill: parent
        anchors.leftMargin: leftPadding
        anchors.rightMargin: rightPadding
        anchors.topMargin: topPadding
        anchors.bottomMargin: bottomPadding
        radius: dpi.value
    }

    Image {
        id: iconImage
        anchors.centerIn: parent
        source: icon
        width: parent.width/1.5
        height: width

        fillMode: Image.PreserveAspectFit

        anchors.horizontalCenterOffset: (leftPadding - rightPadding) / 2

        sourceSize.width: (sourceWidth == -1) ? width : sourceWidth
        sourceSize.height: (sourceHeight == -1) ? height : sourceHeight
    }

    ColorOverlay {
        anchors.fill: iconImage
        source: iconImage
        color: (themeVariantConfig.value == "dark") ? "#ffffff" : "#000000"
    }

    Text {
        id: text
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: Math.round((leftPadding - rightPadding) / 2)
        width: parent.width - leftPadding - rightPadding - 4
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "sans"
        font.weight: Font.Light
        fontSizeMode: Text.HorizontalFit
        font.pixelSize: 3 * dpi.value
        color: (themeVariantConfig.value == "dark") ? "#ffffff" : "#000000"
        text: caption
    }
}
