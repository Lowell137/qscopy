import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import QtQuick.Effects
import "../common"

Rectangle {
    id: rootItem
    width: parent ? parent.width : 400

    property string type: "text"
    property string content: ""
    property int timestamp: 0
    property var pinned: 0
    readonly property bool isPinned: pinned ? true : false

    property color colOnSurface: "#e4e1e7"
    property color colOnSurfaceVariant: "#c6c5d1"
    property color colSurface: "#1f1f23"
    property color colSurfaceHigh: "#292a2e"
    property color colPrimary: "#b7c4ff"
    property color colPrimaryContainer: "#6674ac"
    property color colOnPrimaryContainer: "#ffffff"
    property color colError: "#ffb4ab"
    property color colOutline: "#8f909a"
    property bool isDarkMode: false

    signal pinToggled(bool value)
    signal deleteRequested()
    signal copyRequested()
    signal hovered(bool isHovered)

    property bool isCurrent: ListView.isCurrentItem
    readonly property bool isActive: itemMouse.containsMouse || isCurrent || deleteMouse.containsMouse || pinMouse.containsMouse

    ColorUtils { id: colorUtils }

    height: 72
    radius: 16
    border.width: isPinned ? 2 : 0
    border.color: colorUtils.applyAlpha(colPrimary, isActive ? 0.6 : 0.3)
    Behavior on border.color { ColorAnimation { duration: 200 } }

    color: {
        if (isCurrent && isActive) return colorUtils.mix(colPrimary, colSurfaceHigh, 0.85);
        if (isActive) return colorUtils.mix(colPrimary, colSurfaceHigh, 0.92);
        return colSurface;
    }

    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

    layer.enabled: isActive
    layer.effect: MultiEffect {
        shadowEnabled: isActive
        shadowColor: colorUtils.applyAlpha(colPrimary, 0.15)
        shadowBlur: 0.3
        shadowVerticalOffset: 2
    }

    Rectangle {
        id: ripple
        width: 0; height: 0; radius: width / 2
        color: colorUtils.applyAlpha(isCurrent ? colOnSurface : colPrimary, 0.15)
        x: 0; y: 0
        visible: false
        NumberAnimation {
            id: rippleAnim
            target: ripple
            property: "width"
            from: 0; to: rootItem.width * 1.5
            duration: 400
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: rippleAnim2
            target: ripple
            property: "height"
            from: 0; to: rootItem.width * 1.5
            duration: 400
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: rippleFade
            target: ripple
            property: "opacity"
            from: 1.0; to: 0.0
            duration: 500
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        anchors.leftMargin: 14
        spacing: 14

        Rectangle {
            width: 48; height: 48
            radius: 14
            color: {
                if (isCurrent && isActive) return colorUtils.applyAlpha(colOnSurface, 0.2);
                if (isActive) return colorUtils.applyAlpha(colPrimary, 0.15);
                return colorUtils.applyAlpha(colOnSurfaceVariant, 0.08);
            }

            Behavior on color { ColorAnimation { duration: 200 } }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                visible: rootItem.type === "image"
                radius: 10
                clip: true
                Image {
                    anchors.fill: parent
                    source: rootItem.type === "image" ? ("file://" + rootItem.content) : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            Text {
                anchors.centerIn: parent
                visible: rootItem.type !== "image"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 24
                color: {
                    if (isCurrent && isActive) return colOnSurface;
                    if (isActive) return colPrimary;
                    return colOnSurfaceVariant;
                }
                text: {
                    var c = rootItem.content;
                    if (!c) return "content_paste";
                    if (rootItem.type === "link") return "link";
                    if (c.trim().startsWith("http")) return "link";
                    if (c.trim().startsWith("$") || c.includes("#!/")) return "terminal";
                    if (c.includes("{") || c.includes("function") || c.includes("class ")) return "code";
                    if (/^\d+$/.test(c.trim())) return "pin";
                    return "content_paste";
                }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: {
                    if (rootItem.type === "image") return content.split('/').pop();
                    return content.replace(/\n/g, " ");
                }
                color: {
                    if (isCurrent && isActive) return colorUtils.mix(colOnSurface, "white", 0.7);
                    if (isActive) return colOnSurface;
                    return colOnSurface;
                }
                font.pixelSize: 13
                font.weight: isActive ? Font.Medium : Font.Normal
                elide: Text.ElideRight
                maximumLineCount: 1
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (rootItem.type === "image") {
                        var name = content.split('/').pop();
                        var ext = name.includes('.') ? name.split('.').pop().toUpperCase() : "FILE";
                        return ext + "  •  Image";
                    }
                    var c = content;
                    if (c.length > 80) return c.substring(0, 80) + "...";
                    return c.length + " chars";
                }
                color: {
                    if (isCurrent && isActive) return colorUtils.applyAlpha(colOnSurface, 0.65);
                    if (isActive) return colorUtils.applyAlpha(colOnSurfaceVariant, 0.8);
                    return colOnSurfaceVariant;
                }
                opacity: 0.7
                font.pixelSize: 11
                elide: Text.ElideRight
                maximumLineCount: 1
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        Rectangle {
            id: pinBtn
            width: 36; height: 36; radius: 18
            color: {
                if (pinMouse.containsMouse && !isPinned) return colorUtils.applyAlpha(colOnSurfaceVariant, 0.15);
                if (pinMouse.containsMouse && isPinned) return colorUtils.applyAlpha(colPrimary, 0.2);
                return "transparent";
            }
            visible: isActive
            scale: pinMouse.containsMouse ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: isPinned ? "keep" : "keep"
                font.family: "Material Symbols Rounded"
                color: {
                    if (isPinned && pinMouse.containsMouse) return "white";
                    if (isPinned) return colPrimary;
                    if (pinMouse.containsMouse) return colOnSurface;
                    return colOnSurfaceVariant;
                }
                font.weight: isPinned ? Font.Bold : Font.Normal
                font.pixelSize: 18
            }

            MouseArea {
                id: pinMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: (mouse) => {
                    pinToggled(!rootItem.isPinned);
                    mouse.accepted = true;
                }
            }
        }

        Rectangle {
            id: deleteBtn
            width: 36; height: 36; radius: 18
            color: deleteMouse.containsMouse ? colError : "transparent"
            visible: isActive
            scale: deleteMouse.containsMouse ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "delete"
                font.family: "Material Symbols Rounded"
                color: {
                    if (deleteMouse.containsMouse) return "white";
                    if (isCurrent && isActive) return colorUtils.applyAlpha(colOnSurface, 0.7);
                    return colOnSurfaceVariant;
                }
                font.pixelSize: 20
            }

            MouseArea {
                id: deleteMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: (mouse) => {
                    deleteRequested();
                    mouse.accepted = true;
                }
            }
        }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: -1
        onEntered: hovered(true)
        onExited: hovered(false)
        onPressed: {
            ripple.x = mouse.x - ripple.width / 2;
            ripple.y = mouse.y - ripple.height / 2;
            ripple.visible = true;
            ripple.opacity = 1.0;
            rippleAnim.restart();
            rippleAnim2.restart();
            rippleFade.restart();
        }
        onReleased: {
            ripple.visible = false;
        }
        onClicked: {
            rootItem.ListView.view.currentIndex = index;
            copyRequested();
        }
    }
}
