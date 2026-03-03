//@ pragma IconTheme Adwaita
//@ pragma UseQApplication
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
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
    implicitHeight: 40
    color: "#000000"

    StatusBar {
        id: statusBar
        anchors.fill: parent
    }

    // Scanline overlay — simulates phosphor CRT screen artifacts
    Canvas {
        anchors.fill: parent
        z: 100
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "rgba(57, 255, 20, 0.10)"
            for (var y = 0; y < height; y += 3) {
                ctx.fillRect(0, y, width, 1)
            }
        }
    }

    VolumeOsd {}

    PanelWindow {
        id: volumePanel
        visible: statusBar.volumePanelOpen
        implicitWidth: 250
        implicitHeight: 600
        color: "#000000"
        border.color: "#1a7a1a"
        border.width: 1
        readonly property PwNode sinkNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink : null
        readonly property PwNode sourceNode: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource : null
        readonly property real sinkVolume: sinkNode && sinkNode.audio ? sinkNode.audio.volume : 0
        readonly property real sourceVolume: sourceNode && sourceNode.audio ? sourceNode.audio.volume : 0

        anchors {
            top: true
            right: true
        }
        margins {
            top: statusBar.height + 8
            right: 16
        }

        function setSinkVolume(v: real) {
            if (sinkNode && sinkNode.audio) {
                sinkNode.audio.volume = v
            }
        }

        function setSourceVolume(v: real) {
            if (sourceNode && sourceNode.audio) {
                sourceNode.audio.volume = v
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "OUT"
                    color: "#39ff14"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "monospace"
                    width: 32
                    horizontalAlignment: Text.AlignHCenter
                }

                Slider {
                    id: sinkSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: volumePanel.sinkVolume
                    onMoved: volumePanel.setSinkVolume(value)

                    background: Rectangle {
                        x: sinkSlider.leftPadding
                        y: sinkSlider.topPadding + sinkSlider.availableHeight / 2 - height / 2
                        width: sinkSlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#0a3300"
                        Rectangle {
                            width: sinkSlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: "#39ff14"
                        }
                    }
                    handle: Rectangle {
                        x: sinkSlider.leftPadding + sinkSlider.visualPosition * (sinkSlider.availableWidth - width)
                        y: sinkSlider.topPadding + sinkSlider.availableHeight / 2 - height / 2
                        width: 10
                        height: 10
                        radius: 5
                        color: "#39ff14"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "IN"
                    color: "#39ff14"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "monospace"
                    width: 32
                    horizontalAlignment: Text.AlignHCenter
                }

                Slider {
                    id: sourceSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: volumePanel.sourceVolume
                    onMoved: volumePanel.setSourceVolume(value)

                    background: Rectangle {
                        x: sourceSlider.leftPadding
                        y: sourceSlider.topPadding + sourceSlider.availableHeight / 2 - height / 2
                        width: sourceSlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#0a3300"
                        Rectangle {
                            width: sourceSlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: "#39ff14"
                        }
                    }
                    handle: Rectangle {
                        x: sourceSlider.leftPadding + sourceSlider.visualPosition * (sourceSlider.availableWidth - width)
                        y: sourceSlider.topPadding + sourceSlider.availableHeight / 2 - height / 2
                        width: 10
                        height: 10
                        radius: 5
                        color: "#39ff14"
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: 2
                color: "#000000"
                border.color: "#0a3300"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "OPEN PAVUCONTROL"
                    color: "#39ff14"
                    font.pixelSize: 12
                    font.family: "monospace"
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        statusBar.volumePanelOpen = false
                        Quickshell.execDetached(["pavucontrol"])
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        Canvas {
            anchors.fill: parent
            z: 100
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = "rgba(57, 255, 20, 0.10)"
                for (var y = 0; y < height; y += 3) {
                    ctx.fillRect(0, y, width, 1)
                }
            }
        }
    }
}
