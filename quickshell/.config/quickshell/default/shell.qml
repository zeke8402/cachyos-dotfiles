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
    color: "#1a1b26"

    StatusBar {
        id: statusBar
        anchors.fill: parent
    }

    VolumeOsd {}

    PanelWindow {
        id: volumePanel
        visible: statusBar.volumePanelOpen
        implicitWidth: 250
        implicitHeight: 600
        color: "#1f2335"
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
                    color: "#c0caf5"
                    font.pixelSize: 11
                    font.bold: true
                    width: 32
                    horizontalAlignment: Text.AlignHCenter
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: volumePanel.sinkVolume
                    onMoved: volumePanel.setSinkVolume(value)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "IN"
                    color: "#c0caf5"
                    font.pixelSize: 11
                    font.bold: true
                    width: 32
                    horizontalAlignment: Text.AlignHCenter
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: volumePanel.sourceVolume
                    onMoved: volumePanel.setSourceVolume(value)
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: 8
                color: "#2a2d44"
                border.color: "#3b4261"

                Text {
                    anchors.centerIn: parent
                    text: "Open Pavucontrol"
                    color: "#c0caf5"
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        statusBar.volumePanelOpen = false
                        Quickshell.execDetached(["pavucontrol"])
                    }
                }
            }
        }
    }
}
