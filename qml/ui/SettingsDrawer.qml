import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../common"

Rectangle {
    id: drawerRoot

    property bool opened: false

    property bool isDarkMode: true
    property bool isAutoDelete: false
    property bool isPasteRightAway: false
    property bool closeOnCopy: true
    property real glassOpacity: 0.6

    property color colOnSurface: "#e4e1e7"
    property color colOnSurfaceVariant: "#c6c5d1"
    property color colSurface: "#1f1f23"
    property color colSurfaceHigh: "#292a2e"
    property color colPrimary: "#b7c4ff"
    property color colPrimaryContainer: "#6674ac"
    property color colOnPrimaryContainer: "#ffffff"
    property color colOutline: "#8f909a"
    property color colOutlineVariant: "#45464f"
    property color colError: "#ffb4ab"

    signal requestClose()
    signal requestDarkMode(bool val)
    signal requestAutoDelete(bool val)
    signal requestPasteRightAway(bool val)
    signal requestCloseOnCopy(bool val)
    signal requestGlassOpacity(real val)
    signal requestClearHistory()

    ColorUtils { id: colorUtils }

    anchors.fill: parent
    color: colorUtils.applyAlpha(colSurface, 0.97)
    radius: 24
    opacity: opened ? 1 : 0
    visible: opacity > 0
    z: 100

    Behavior on opacity { NumberAnimation { duration: 250 } }

    onGlassOpacityChanged: glassSlider.sliderValue = glassOpacity

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 24
            Layout.leftMargin: 24
            Layout.rightMargin: 24

            Text {
                text: "Settings"
                color: colOnSurface
                font.pixelSize: 20
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            Rectangle {
                width: 32; height: 32; radius: 16
                color: closeMouse.containsMouse ? colorUtils.applyAlpha(colOnSurface, 0.1) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "close"
                    font.family: "Material Symbols Rounded"
                    color: colOnSurface
                    font.pixelSize: 18
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: requestClose()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: colorUtils.applyAlpha(colOutlineVariant, 0.4)
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: column.implicitHeight + 40
            clip: true
            topMargin: 8
            bottomMargin: 16

            ColumnLayout {
                id: column
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontal
                spacing: 6

                Text {
                    text: "Glass: " + Math.round(drawerRoot.glassOpacity * 100) + "%"
                    color: colOnSurfaceVariant
                    font.pixelSize: 13
                    Layout.topMargin: 8
                }

                Item {
                    id: glassSlider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4

                    property real from: 0.0
                    property real to: 1.0
                    property real stepSize: 0.01
                    property real sliderValue: 0.5

                    function posToVal(x) {
                        var p = Math.max(0, Math.min(1, x / (width - 20)));
                        var raw = from + p * (to - from);
                        return Math.round(raw / stepSize) * stepSize;
                    }

                    function valToPos(v) {
                        var p = (v - from) / (to - from);
                        return p * (width - 20);
                    }

                    onSliderValueChanged: {
                        if (!handle.dragging) handle.x = valToPos(sliderValue);
                    }

                    Component.onCompleted: {
                        sliderValue = drawerRoot.glassOpacity;
                        handle.x = valToPos(sliderValue);
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10; width: parent.width - 20; height: 4; radius: 2
                        color: drawerRoot.colOnSurfaceVariant; opacity: 0.3
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                        width: Math.max(0, handle.x + handle.width / 2 - 10)
                        height: 4; radius: 2
                        color: drawerRoot.colPrimary
                    }

                    Rectangle {
                        id: handle
                        y: (parent.height - height) / 2
                        width: 20; height: 20; radius: 10
                        color: drawerRoot.colPrimary
                        Behavior on color { ColorAnimation { duration: 100 } }
                        z: 1

                        property bool dragging: false

                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            drag.target: parent
                            drag.axis: Drag.XAxis
                            drag.minimumX: 0
                            drag.maximumX: glassSlider.width - parent.width
                            onPressed: handle.dragging = true
                            onPositionChanged: {
                                glassSlider.sliderValue = glassSlider.posToVal(handle.x);
                            }
                            onReleased: {
                                glassSlider.sliderValue = glassSlider.posToVal(handle.x);
                                handle.dragging = false;
                                requestGlassOpacity(glassSlider.sliderValue);
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            glassSlider.sliderValue = glassSlider.posToVal(mouse.x - 10);
                            requestGlassOpacity(glassSlider.sliderValue);
                            handle.x = glassSlider.valToPos(glassSlider.sliderValue);
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colorUtils.applyAlpha(colOutlineVariant, 0.2); Layout.topMargin: 8; Layout.bottomMargin: 4 }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    spacing: 12
                    Text { text: "Dark mode"; color: colOnSurface; font.pixelSize: 14; Layout.fillWidth: true }

                    Switch {
                        id: darkSwitch
                        checked: drawerRoot.isDarkMode
                        onCheckedChanged: requestDarkMode(checked)

                        indicator: Rectangle {
                            x: darkSwitch.leftPadding
                            y: darkSwitch.topPadding + darkSwitch.availableHeight / 2 - height / 2
                            width: 44
                            height: 24
                            radius: 12
                            color: darkSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                            opacity: darkSwitch.checked ? 0.5 : 0.2
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                x: darkSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 20
                                height: 20
                                radius: 10
                                color: darkSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colorUtils.applyAlpha(colOutlineVariant, 0.2) }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    spacing: 12
                    Text { text: "Close on copy"; color: colOnSurface; font.pixelSize: 14; Layout.fillWidth: true }

                    Switch {
                        id: closeSwitch
                        checked: drawerRoot.closeOnCopy
                        onCheckedChanged: requestCloseOnCopy(checked)

                        indicator: Rectangle {
                            x: closeSwitch.leftPadding
                            y: closeSwitch.topPadding + closeSwitch.availableHeight / 2 - height / 2
                            width: 44
                            height: 24
                            radius: 12
                            color: closeSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                            opacity: closeSwitch.checked ? 0.5 : 0.2
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                x: closeSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 20
                                height: 20
                                radius: 10
                                color: closeSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colorUtils.applyAlpha(colOutlineVariant, 0.2) }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    spacing: 12
                    Text { text: "Auto delete"; color: colOnSurface; font.pixelSize: 14; Layout.fillWidth: true }

                    Switch {
                        id: autoSwitch
                        checked: drawerRoot.isAutoDelete
                        onCheckedChanged: requestAutoDelete(checked)

                        indicator: Rectangle {
                            x: autoSwitch.leftPadding
                            y: autoSwitch.topPadding + autoSwitch.availableHeight / 2 - height / 2
                            width: 44
                            height: 24
                            radius: 12
                            color: autoSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                            opacity: autoSwitch.checked ? 0.5 : 0.2
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                x: autoSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 20
                                height: 20
                                radius: 10
                                color: autoSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: colorUtils.applyAlpha(colOutlineVariant, 0.2) }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    spacing: 12
                    Text { text: "Paste right away"; color: colOnSurface; font.pixelSize: 14; Layout.fillWidth: true }

                    Switch {
                        id: pasteSwitch
                        checked: drawerRoot.isPasteRightAway
                        onCheckedChanged: requestPasteRightAway(checked)

                        indicator: Rectangle {
                            x: pasteSwitch.leftPadding
                            y: pasteSwitch.topPadding + pasteSwitch.availableHeight / 2 - height / 2
                            width: 44
                            height: 24
                            radius: 12
                            color: pasteSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                            opacity: pasteSwitch.checked ? 0.5 : 0.2
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                x: pasteSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 20
                                height: 20
                                radius: 10
                                color: pasteSwitch.checked ? drawerRoot.colPrimary : drawerRoot.colOnSurfaceVariant
                                Behavior on x { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 12 }

                Button {
                    id: clearBtn
                    text: "Clear history"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    Layout.bottomMargin: 8
                    onClicked: requestClearHistory()
                    leftPadding: 16
                    rightPadding: 16

                    background: Rectangle {
                        radius: 14
                        color: parent.hovered ? colorUtils.mix(colError, colSurface, 0.85) : colorUtils.applyAlpha(colError, 0.12)
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "delete_forever"
                                font.family: "Material Symbols Rounded"
                                color: colError
                                font.pixelSize: 18
                            }

                            Text {
                                text: clearBtn.text
                                color: colError
                                font.pixelSize: 14
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }
    }
}
