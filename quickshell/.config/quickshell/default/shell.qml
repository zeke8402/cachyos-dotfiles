import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell._Window
import Quickshell.Wayland._WlrLayerShell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

WlrLayershell {
    layer: WlrLayer.Top
    namespace: "quickshell"
    keyboardFocus: WlrKeyboardFocus.None
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: "#1a1b26"

    component VolumeWidget: Item {
        id: volumeRoot
        property bool drawerOpen: false
        readonly property PwNode sinkNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink : null
        readonly property PwNode sourceNode: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource : null
        readonly property real sinkVolume: sinkNode && sinkNode.audio ? sinkNode.audio.volume : 0
        readonly property int volumePercent: Math.max(0, Math.min(100, Math.round(sinkVolume * 100)))
        readonly property int waveLevel: volumePercent >= 67 ? 3 : (volumePercent >= 34 ? 2 : (volumePercent > 0 ? 1 : 0))

        implicitWidth: 34
        implicitHeight: 22
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight

        onWaveLevelChanged: volumeIcon.requestPaint()
        onSinkVolumeChanged: volumeIcon.requestPaint()

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].filter(node => node)
        }

        function setSinkVolume(v: real) {
            if (sinkNode && sinkNode.audio) {
                sinkNode.audio.volume = v
            }
        }

        function nodeLabel(n) {
            if (!n) return ""
            return n.nickname || n.description || n.name
        }

        Rectangle {
            id: volumeButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 22
            radius: 6
            color: drawerOpen ? "#2a2d44" : "#1f2335"
            border.color: "#3b4261"

            Canvas {
                id: volumeIcon
                anchors.centerIn: parent
                width: 22
                height: 16
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.fillStyle = "#c0caf5"
                    ctx.strokeStyle = "#c0caf5"
                    ctx.lineWidth = 1.6

                    ctx.beginPath()
                    ctx.rect(1, 5, 4, 6)
                    ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(5, 4)
                    ctx.lineTo(10, 2)
                    ctx.lineTo(10, 14)
                    ctx.lineTo(5, 12)
                    ctx.closePath()
                    ctx.fill()

                    var levels = volumeRoot.waveLevel
                    for (var i = 1; i <= levels; i++) {
                        var r = 2 + i * 3
                        ctx.beginPath()
                        ctx.arc(10, 8, r, -0.6, 0.6)
                        ctx.stroke()
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: volumeRoot.drawerOpen = !volumeRoot.drawerOpen
            }
        }

        function updateDrawerPosition() {
            if (!drawerWindow.parentWindow || !drawerWindow.visible) return
            var p = volumeButton.mapToItem(null, 0, 0)
            drawerWindow.relativeX = Math.round(p.x + volumeButton.width - drawerWindow.width)
            drawerWindow.relativeY = Math.round(p.y + volumeButton.height + 6)
            drawerWindow.reposition()
        }

        onDrawerOpenChanged: {
            if (drawerOpen) {
                updateDrawerPosition()
            }
        }

        PopupWindow {
            id: drawerWindow
            parentWindow: volumeRoot.window ? volumeRoot.window : null
            color: "transparent"
            implicitWidth: 240
            implicitHeight: drawerOpen ? (drawerContent.implicitHeight + 16) : 0
            width: implicitWidth
            visible: drawerOpen

            onWidthChanged: updateDrawerPosition()
            onImplicitHeightChanged: updateDrawerPosition()
            onVisibleChanged: updateDrawerPosition()

            Behavior on implicitHeight {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Item {
                anchors.fill: parent
                clip: true

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "#1f2335"
                    border.color: "#3b4261"
                }

                ColumnLayout {
                    id: drawerContent
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    Text {
                        text: "Volumee"
                        color: "#7aa2f7"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Slider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        value: volumeRoot.sinkVolume
                        onMoved: volumeRoot.setSinkVolume(value)
                    }

                    Text {
                        text: volumeRoot.volumePercent + "%"
                        color: "#c0caf5"
                        font.pixelSize: 11
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#3b4261"
                    }

                    Text {
                        text: "Output"
                        color: "#9aa5ce"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: Pipewire.nodes
                            delegate: Item {
                                readonly property bool isOutput: modelData && modelData.audio && !modelData.isStream && modelData.isSink
                                visible: isOutput
                                Layout.fillWidth: true
                                height: isOutput ? 24 : 0

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    color: modelData === Pipewire.defaultAudioSink ? "#2a2d44" : "transparent"
                                    border.color: modelData === Pipewire.defaultAudioSink ? "#7aa2f7" : "transparent"
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    text: volumeRoot.nodeLabel(modelData)
                                    color: "#c0caf5"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width - 16
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                                }
                            }
                        }
                    }

                    Text {
                        text: "Input"
                        color: "#9aa5ce"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: Pipewire.nodes
                            delegate: Item {
                                readonly property bool isInput: modelData && modelData.audio && !modelData.isStream && !modelData.isSink
                                visible: isInput
                                Layout.fillWidth: true
                                height: isInput ? 24 : 0

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    color: modelData === Pipewire.defaultAudioSource ? "#2a2d44" : "transparent"
                                    border.color: modelData === Pipewire.defaultAudioSource ? "#7aa2f7" : "transparent"
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    text: volumeRoot.nodeLabel(modelData)
                                    color: "#c0caf5"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width - 16
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Pipewire.preferredDefaultAudioSource = modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        Repeater {
            model: 9

            Text {
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
                font { pixelSize: 14; bold: true }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }

        Item { Layout.fillWidth: true }

        VolumeWidget {}
    }
}
