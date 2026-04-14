import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import "config.js" as Config

PanelWindow {
    id: settingsPanel

    property bool open: false
    property real statusBarHeight: 0
    signal closeRequested()

    // Visibility is managed manually so we can delay hide until close animation finishes
    visible: _shown
    property bool _shown: false

    implicitWidth:  380
    implicitHeight: 500
    color: "#1d2021"

    onOpenChanged: {
        if (open) {
            content.x = settingsPanel.implicitWidth
            _shown = true
            slideIn.restart()
        } else {
            slideOut.restart()
        }
    }

    readonly property PwNode sinkNode:   Pipewire.defaultAudioSink   ? Pipewire.defaultAudioSink   : null
    readonly property PwNode sourceNode: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource : null
    readonly property real sinkVolume:   sinkNode   && sinkNode.audio   ? sinkNode.audio.volume   : 0
    readonly property real sourceVolume: sourceNode && sourceNode.audio ? sourceNode.audio.volume : 0

    anchors {
        top:   true
        right: true
    }
    margins {
        top:   statusBarHeight + 8
        right: 12
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].filter(n => n)
    }

    function setSinkVolume(v: real) {
        if (sinkNode   && sinkNode.audio)   sinkNode.audio.volume   = v
    }
    function setSourceVolume(v: real) {
        if (sourceNode && sourceNode.audio) sourceNode.audio.volume = v
    }

    // ── Animated content wrapper ──────────────────────────────────────────
    Item {
        id: content
        width:  parent.width
        height: parent.height

        NumberAnimation {
            id: slideIn
            target:   content
            property: "x"
            to:       0
            duration: 220
            easing.type: Easing.OutQuint
        }
        NumberAnimation {
            id: slideOut
            target:   content
            property: "x"
            to:       settingsPanel.implicitWidth
            duration: 180
            easing.type: Easing.InCubic
            onStopped: settingsPanel._shown = false
        }

        ColumnLayout {
            anchors.fill:    parent
            anchors.margins: 12
            spacing: 10

            // ── Volume ────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                radius: 10
                color:  "#282828"
                implicitHeight: volCol.implicitHeight + 28

                ColumnLayout {
                    id: volCol
                    anchors {
                        left:    parent.left
                        right:   parent.right
                        top:     parent.top
                        margins: 14
                    }
                    spacing: 14

                    // Section label
                    Text {
                        text: "Volume"
                        color: "#a89984"
                        font.family:         "Lexend"
                        font.pixelSize:      13
                        font.letterSpacing:  0.8
                        font.capitalization: Font.AllUppercase
                    }

                    // ── Output ───────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Output"
                                color: "#ebdbb2"
                                font.family:    "Lexend"
                                font.pixelSize: 16
                                Layout.fillWidth: true
                            }
                            Text {
                                text: Math.round(settingsPanel.sinkVolume * 100) + "%"
                                color: "#a89984"
                                font.family:    "Lexend"
                                font.pixelSize: 14
                            }
                        }

                        Item {
                            id: outputSlider
                            Layout.fillWidth: true
                            height: 20
                            property real sliderValue: settingsPanel.sinkVolume

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width:  parent.width
                                height: 5
                                radius: 3
                                color:  "#3c3836"

                                Rectangle {
                                    width:  parent.width * Math.min(outputSlider.sliderValue, 1.5)
                                    height: parent.height
                                    radius: parent.radius
                                    color:  outputSlider.sliderValue > 1.0  ? "#fb4934"
                                          : outputSlider.sliderValue > 0.95 ? "#fe8019"
                                          : "#fabd2f"
                                }
                            }
                            // Thumb
                            Rectangle {
                                x: outputSlider.sliderValue * (parent.width - width)
                                anchors.verticalCenter: parent.verticalCenter
                                width: 14; height: 14; radius: 7
                                color: "#ebdbb2"
                            }
                            MouseArea {
                                id: sinkMA
                                anchors.fill: parent
                                function applyX(mx) {
                                    var v = Math.max(0, Math.min(1.5, mx / width))
                                    outputSlider.sliderValue = v
                                    settingsPanel.setSinkVolume(v)
                                }
                                onPressed:         (mouse) => applyX(mouse.x)
                                onPositionChanged: (mouse) => applyX(mouse.x)
                            }
                            Connections {
                                target: settingsPanel
                                function onSinkVolumeChanged() {
                                    if (!sinkMA.pressed)
                                        outputSlider.sliderValue = settingsPanel.sinkVolume
                                }
                            }
                        }
                    }

                    // ── Input ────────────────────────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Input"
                                color: "#ebdbb2"
                                font.family:    "Lexend"
                                font.pixelSize: 16
                                Layout.fillWidth: true
                            }
                            Text {
                                text: Math.round(settingsPanel.sourceVolume * 100) + "%"
                                color: "#a89984"
                                font.family:    "Lexend"
                                font.pixelSize: 14
                            }
                        }

                        Item {
                            id: inputSlider
                            Layout.fillWidth: true
                            height: 20
                            property real sliderValue: settingsPanel.sourceVolume

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width:  parent.width
                                height: 5
                                radius: 3
                                color:  "#3c3836"

                                Rectangle {
                                    width:  parent.width * Math.min(inputSlider.sliderValue, 1)
                                    height: parent.height
                                    radius: parent.radius
                                    color:  "#83a598"
                                }
                            }
                            // Thumb
                            Rectangle {
                                x: inputSlider.sliderValue * (parent.width - width)
                                anchors.verticalCenter: parent.verticalCenter
                                width: 14; height: 14; radius: 7
                                color: "#ebdbb2"
                            }
                            MouseArea {
                                id: sourceMA
                                anchors.fill: parent
                                function applyX(mx) {
                                    var v = Math.max(0, Math.min(1, mx / width))
                                    inputSlider.sliderValue = v
                                    settingsPanel.setSourceVolume(v)
                                }
                                onPressed:         (mouse) => applyX(mouse.x)
                                onPositionChanged: (mouse) => applyX(mouse.x)
                            }
                            Connections {
                                target: settingsPanel
                                function onSourceVolumeChanged() {
                                    if (!sourceMA.pressed)
                                        inputSlider.sliderValue = settingsPanel.sourceVolume
                                }
                            }
                        }
                    }

                    // ── Output device selector ────────────────────────────
                    RowLayout {
                        id: deviceRow
                        Layout.fillWidth: true
                        spacing: 8

                        readonly property string activeSink: settingsPanel.sinkNode
                                                           ? settingsPanel.sinkNode.name : ""

                        Rectangle {
                            Layout.fillWidth: true
                            height: 34
                            radius: 8
                            color: deviceRow.activeSink === Config.speakerSink ? "#fe8019" : "#3c3836"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text:  "Speakers"
                                color: deviceRow.activeSink === Config.speakerSink ? "#1d2021" : "#ebdbb2"
                                font.family:    "Lexend"
                                font.pixelSize: 16
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["pactl", "set-default-sink", Config.speakerSink])
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 34
                            radius: 8
                            color: deviceRow.activeSink === Config.headsetSink ? "#fe8019" : "#3c3836"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text:  "Headset"
                                color: deviceRow.activeSink === Config.headsetSink ? "#1d2021" : "#ebdbb2"
                                font.family:    "Lexend"
                                font.pixelSize: 16
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["pactl", "set-default-sink", Config.headsetSink])
                            }
                        }
                    }

                    // ── Open Mixer ────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        height: 34
                        radius: 8
                        color: mixerMa.containsMouse ? "#504945" : "#3c3836"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text:  "Open Mixer"
                            color: "#ebdbb2"
                            font.family:    "Lexend"
                            font.pixelSize: 16
                        }
                        MouseArea {
                            id: mixerMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                settingsPanel.closeRequested()
                                Quickshell.execDetached(["pavucontrol"])
                            }
                        }
                    }
                }
            }

            // ── Drive space ───────────────────────────────────────────────
            DriveSpace {}

            Item { Layout.fillHeight: true }
        }
    }
}
