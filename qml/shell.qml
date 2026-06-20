import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "backend"
import "ui"
import "common"

ShellRoot {
    id: root

    ListModel { id: listModel }

    QScopyBackend {
        id: backend
        targetModel: listModel
    }

    ColorUtils { id: colorUtils }

    property var scheme: ({})
    property int schemeVersion: 0
    property var hoveredItem: null
    property real previewOpacity: hoveredItem ? 1.0 : 0.0
    property real panelScale: 1.0

    function sc(key, fallback) {
        return fallback;
    }

    Component.onCompleted: {
        backend.init();
        panelEnter.restart();
        listView.forceActiveFocus();
    }

    NumberAnimation {
        id: panelEnter
        target: root
        property: "panelScale"
        from: 0.92; to: 1.0
        duration: 400
        easing.type: Easing.OutCubic
    }

    PanelWindow {
        id: mainWindow
        implicitWidth: 1400; implicitHeight: 700
        visible: true; color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:qscopy"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        property bool isDarkMode: backend.isDarkMode

        property color colBg: isDarkMode ? "#000000" : "#fafafa"
        property color colOnBg: isDarkMode ? "#e4e1e7" : "#1a1a1a"
        property color colSurface: isDarkMode ? "#0d0d0d" : "#f0f0f0"
        property color colSurfaceHigh: isDarkMode ? "#1a1a1a" : "#e8e8e8"
        property color colSurfaceHighest: isDarkMode ? "#262626" : "#e0e0e0"
        property color colSurfaceLow: isDarkMode ? "#050505" : "#f5f5f5"
        property color colOnSurface: isDarkMode ? "#e4e1e7" : "#1a1a1a"
        property color colOnSurfaceVariant: isDarkMode ? "#c6c5d1" : "#49454f"
        property color colPrimary: isDarkMode ? "#e4e1e7" : "#1a1a1a"
        property color colOnPrimary: isDarkMode ? "#1e2d60" : "#fafafa"
        property color colPrimaryContainer: isDarkMode ? "#303034" : "#d0d0d0"
        property color colOnPrimaryContainer: isDarkMode ? "#ffffff" : "#1a1a1a"
        property color colSecondary: isDarkMode ? "#c1c5e0" : "#5a5a5a"
        property color colTertiary: isDarkMode ? "#f1b3e6" : "#7a5a7a"
        property color colOutline: isDarkMode ? "#45464f" : "#79747e"
        property color colOutlineVariant: isDarkMode ? "#35353a" : "#c4c1ca"
        property color colError: isDarkMode ? "#ffb4ab" : "#b3261e"
        property color colShadow: "#000000"
        property color colSurfaceTint: isDarkMode ? "#e4e1e7" : "#1a1a1a"

        Behavior on colBg { ColorAnimation { duration: 600 } }
        Behavior on colOnBg { ColorAnimation { duration: 600 } }
        Behavior on colSurface { ColorAnimation { duration: 600 } }
        Behavior on colSurfaceHigh { ColorAnimation { duration: 600 } }
        Behavior on colOnSurface { ColorAnimation { duration: 600 } }
        Behavior on colOnSurfaceVariant { ColorAnimation { duration: 600 } }
        Behavior on colPrimary { ColorAnimation { duration: 600 } }
        Behavior on colOutline { ColorAnimation { duration: 600 } }
        Behavior on colOutlineVariant { ColorAnimation { duration: 600 } }

        Item {
            anchors.fill: parent; focus: true
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    if (settingsDrawer.opened) settingsDrawer.opened = false;
                    else Qt.quit();
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) { listView.decrementCurrentIndex(); event.accepted = true }
                else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) { listView.incrementCurrentIndex(); event.accepted = true }
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { if (listView.currentIndex >= 0) backend.copyItem(listModel.get(listView.currentIndex).id); event.accepted = true }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { if (!settingsDrawer.opened) Qt.quit(); }
                z: -1
            }

            Item {
                anchors.centerIn: parent
                width: mainRect.width + previewIsland.width + (previewIsland.visible ? 24 : 0)
                height: Math.max(mainRect.height, previewIsland.visible ? previewIsland.height : 0)
                scale: root.panelScale
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                Rectangle {
                    id: mainRect
                    width: 480; height: 660
                    radius: 28
                    color: colorUtils.applyAlpha(mainWindow.colSurface, backend.glassOpacity)
                    border.color: mainWindow.colOutlineVariant
                    border.width: 1
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: colorUtils.applyAlpha(mainWindow.colShadow, 0.5)
                        shadowBlur: 0.8
                        shadowVerticalOffset: 8
                        shadowHorizontalOffset: 0
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 0
                        spacing: 0

                        TitleBar {
                            Layout.fillWidth: true
                            colOnSurface: mainWindow.colOnSurface
                            colOnSurfaceVariant: mainWindow.colOnSurfaceVariant
                            colPrimary: mainWindow.colPrimary
                            colSurface: mainWindow.colSurface
                            colOutline: mainWindow.colOutline
                            colSurfaceHigh: mainWindow.colSurfaceHigh
                            isDarkMode: backend.isDarkMode
                            onSearchChanged: text => backend.search(text)
                            onSettingsClicked: settingsDrawer.opened = true
                            onSearchFinished: listView.forceActiveFocus()
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: mainWindow.colOutlineVariant
                            opacity: 0.3
                        }

                        ListView {
                            id: listView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.topMargin: 8
                            Layout.bottomMargin: 12
                            spacing: 8
                            clip: true
                            focus: true
                            model: listModel
                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Up || event.key === Qt.Key_K) { listView.decrementCurrentIndex(); event.accepted = true }
                                else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) { listView.incrementCurrentIndex(); event.accepted = true }
                                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { if (listView.currentIndex >= 0) backend.copyItem(listModel.get(listView.currentIndex).id) }
                            }
                            onCurrentIndexChanged: if (currentIndex >= 0 && currentIndex < model.count) root.hoveredItem = model.get(currentIndex)

                            delegate: ClipboardItem {
                                width: listView.width - 4
                                type: model.type
                                content: model.content
                                timestamp: model.timestamp
                                pinned: model.pinned
                                isCurrent: ListView.isCurrentItem
                                colOnSurface: mainWindow.colOnSurface
                                colOnSurfaceVariant: mainWindow.colOnSurfaceVariant
                                colSurface: mainWindow.colSurface
                                colSurfaceHigh: mainWindow.colSurfaceHigh
                                colPrimary: mainWindow.colPrimary
                                colPrimaryContainer: mainWindow.colPrimaryContainer
                                colOnPrimaryContainer: mainWindow.colOnPrimaryContainer
                                colError: mainWindow.colError
                                colOutline: mainWindow.colOutline
                                isDarkMode: backend.isDarkMode
                                onHovered: (isHovered) => { if (isHovered) root.hoveredItem = model; else if (root.hoveredItem === model) root.hoveredItem = null; }
                                onCopyRequested: backend.copyItem(model.id)
                                onDeleteRequested: backend.deleteItem(model.id)
                                onPinToggled: val => backend.pinItem(model.id, val)
                            }
                        }
                    }
                }

                Rectangle {
                    id: previewIsland
                    x: mainRect.width + 24
                    y: (parent.height - height) / 2
                    width: 380
                    height: Math.min(600, Math.max(180, previewContent.implicitHeight + 64))
                    radius: 28
                    color: colorUtils.applyAlpha(mainWindow.colSurface, backend.glassOpacity)
                    border.color: mainWindow.colOutlineVariant
                    border.width: 1
                    opacity: root.previewOpacity
                    visible: opacity > 0
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: colorUtils.applyAlpha(mainWindow.colShadow, 0.4)
                        shadowBlur: 0.7
                        shadowVerticalOffset: 4
                    }

                    Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                    Behavior on x { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

                    ColumnLayout {
                        id: previewContent
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 16

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: "preview"
                                font.family: "Material Symbols Rounded"
                                font.pixelSize: 20
                                color: mainWindow.colOnSurfaceVariant
                                opacity: 0.7
                            }
                            Text {
                                text: "Preview"
                                color: mainWindow.colOnSurfaceVariant
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1
                                opacity: 0.7
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: root.hoveredItem && root.hoveredItem.type === "image" ? "image" : "text_snippet"
                                font.family: "Material Symbols Rounded"
                                font.pixelSize: 18
                                color: mainWindow.colPrimary
                                opacity: 0.8
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.hoveredItem && root.hoveredItem.type === "image" ? 320 : Math.min(420, previewText.implicitHeight + 48)
                            color: colorUtils.applyAlpha(mainWindow.colSurfaceHigh, 0.5)
                            radius: 20
                            clip: true

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 4
                                contentWidth: parent.width
                                contentHeight: previewText.implicitHeight
                                clip: true
                                interactive: root.hoveredItem && root.hoveredItem.type !== "image"

                                Text {
                                    id: previewText
                                    width: parent.width - 32
                                    anchors.horizontalCenter: parent.horizontal
                                    anchors.top: parent.top
                                    anchors.topMargin: 16
                                    text: (root.hoveredItem && root.hoveredItem.type !== "image") ? root.hoveredItem.content : ""
                                    color: mainWindow.colOnSurface
                                    font.pixelSize: 14
                                    lineHeight: 1.6
                                    wrapMode: Text.Wrap
                                    visible: root.hoveredItem && root.hoveredItem.type !== "image"

                                }
                            }

                            Image {
                                anchors.fill: parent
                                anchors.margins: 12
                                fillMode: Image.PreserveAspectFit
                                visible: root.hoveredItem && root.hoveredItem.type === "image"
                                source: root.hoveredItem && root.hoveredItem.type === "image" ? ("file://" + root.hoveredItem.content) : ""
                                asynchronous: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            Text {
                                text: {
                                    if (!root.hoveredItem) return "";
                                    if (root.hoveredItem.type === "image") return "image";
                                    return "article";
                                }
                                font.family: "Material Symbols Rounded"
                                font.pixelSize: 16
                                color: mainWindow.colOnSurfaceVariant
                                opacity: 0.6
                            }
                            Text {
                                text: {
                                    if (!root.hoveredItem) return "";
                                    if (root.hoveredItem.type === "image") return "Image file";
                                    var c = root.hoveredItem.content;
                                    return (c ? c.length : 0) + " chars  •  " + (c ? c.split(/\s+/).length : 0) + " words";
                                }
                                color: mainWindow.colOnSurfaceVariant
                                opacity: 0.5
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }
                    }
                }
            }
        }

        SettingsDrawer {
            id: settingsDrawer
            opened: false
            isDarkMode: backend.isDarkMode
            isAutoDelete: backend.isAutoDelete
            isPasteRightAway: backend.isPasteRightAway
            closeOnCopy: backend.closeOnCopy
            glassOpacity: backend.glassOpacity
            colOnSurface: mainWindow.colOnSurface
            colOnSurfaceVariant: mainWindow.colOnSurfaceVariant
            colSurface: mainWindow.colSurface
            colSurfaceHigh: mainWindow.colSurfaceHigh
            colPrimary: mainWindow.colPrimary
            colPrimaryContainer: mainWindow.colPrimaryContainer
            colOnPrimaryContainer: mainWindow.colOnPrimaryContainer
            colOutline: mainWindow.colOutline
            colOutlineVariant: mainWindow.colOutlineVariant
            colError: mainWindow.colError
            onRequestClose: opened = false
            onRequestDarkMode: val => backend.setDarkMode(val)
            onRequestAutoDelete: val => backend.setAutoDelete(val)
            onRequestPasteRightAway: val => backend.setPasteRightAway(val)
            onRequestCloseOnCopy: val => backend.setCloseOnCopy(val)
            onRequestGlassOpacity: val => backend.setGlassOpacity(val)
            onRequestClearHistory: { backend.clearHistory(); opened = false }
        }
    }
}
