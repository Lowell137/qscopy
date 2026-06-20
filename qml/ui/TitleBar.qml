import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../common"

ColumnLayout {
    id: rootTitle

    signal searchChanged(string text)
    signal settingsClicked()
    readonly property alias searchFocused: searchFocus.activeFocus
    signal searchFinished()

    property color colOnSurface: "#e4e1e7"
    property color colOnSurfaceVariant: "#c6c5d1"
    property color colPrimary: "#b7c4ff"
    property color colSurface: "#1f1f23"
    property color colOutline: "#8f909a"
    property color colSurfaceHigh: "#292a2e"
    property bool isDarkMode: false

    ColorUtils { id: colorUtils }

    spacing: 0

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 16
        Layout.leftMargin: 20
        Layout.rightMargin: 16
        Layout.bottomMargin: 12
        spacing: 12

        Text {
            text: "content_paste"
            font.family: "Material Symbols Rounded"
            font.pixelSize: 22
            color: colPrimary
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "Clipboard"
            font.pixelSize: 20
            font.weight: Font.Medium
            color: colOnSurface
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            width: 34; height: 34; radius: 17
            color: gearBtn.containsMouse ? colorUtils.applyAlpha(colOnSurfaceVariant, 0.1) : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "settings"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 20
                color: colOnSurfaceVariant
                Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                rotation: gearBtn.containsMouse ? 45 : 0
            }

            MouseArea {
                id: gearBtn
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: settingsClicked()
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        Layout.bottomMargin: 12
        height: 42
        radius: 12
        color: colorUtils.applyAlpha(colSurfaceHigh, 0.6)
        border.color: searchFocus.activeFocus ? colPrimary : colorUtils.applyAlpha(colOutline, 0.2)
        border.width: searchFocus.activeFocus ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 8
            spacing: 10

            Text {
                text: "search"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 20
                color: searchFocus.activeFocus ? colPrimary : colorUtils.applyAlpha(colOnSurfaceVariant, 0.5)
                opacity: searchFocus.text ? 1.0 : 0.6
                Behavior on color { ColorAnimation { duration: 150 } }
                Layout.alignment: Qt.AlignVCenter
            }

            TextField {
                id: searchFocus
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                placeholderText: "Search clipboard..."
                placeholderTextColor: colorUtils.applyAlpha(colOnSurfaceVariant, 0.4)
                color: colOnSurface
                font.pixelSize: 14
                verticalAlignment: TextInput.AlignVCenter
                padding: 0
                leftPadding: 0
                background: Item {}
                selectByMouse: true
                onTextChanged: searchChanged(text)
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        searchFinished();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                        searchFinished();
                        event.accepted = true;
                    }
                }
            }

            Rectangle {
                width: searchFocus.text ? 28 : 0
                height: searchFocus.text ? 28 : 0
                radius: 14
                visible: searchFocus.text.length > 0
                color: colorUtils.applyAlpha(colOnSurfaceVariant, 0.1)

                Text {
                    anchors.centerIn: parent
                    text: "close"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 16
                    color: colOnSurfaceVariant
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        searchFocus.text = "";
                        searchFocus.forceActiveFocus();
                    }
                }

                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
        }
    }
}
