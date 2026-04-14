import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    property bool shouldShowOsd: false
    readonly property PwNode sinkNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink : null
    readonly property real sinkVolume: sinkNode && sinkNode.audio ? sinkNode.audio.volume : 0

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink].filter(node => node)
    }

    onSinkVolumeChanged: {
        root.shouldShowOsd = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.bottom: true
            margins.bottom: 52
            exclusiveZone: 0

            implicitWidth: 300
            implicitHeight: 56
            color: "transparent"
            mask: Region {}

            // Drop shadow layer
            Rectangle {
                anchors.fill: pill
                anchors.margins: -1
                anchors.topMargin: 2
                radius: pill.radius + 1
                color: "#0d1117"
                opacity: 0.5
            }

            // Pill container
            Rectangle {
                id: pill
                anchors.fill: parent
                color: "#282828"
                radius: 28
                border.color: "#3c3836"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 14

                    // Speaker icon
                    Canvas {
                        id: speakerIcon
                        implicitWidth: 22
                        implicitHeight: 22
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.fillStyle   = "#fabd2f"
                            ctx.strokeStyle = "#fabd2f"
                            ctx.lineWidth   = 1.8

                            // Speaker body
                            ctx.beginPath()
                            ctx.rect(2, 8, 5, 6)
                            ctx.fill()

                            // Horn
                            ctx.beginPath()
                            ctx.moveTo(7,  7)
                            ctx.lineTo(14, 4)
                            ctx.lineTo(14, 18)
                            ctx.lineTo(7,  15)
                            ctx.closePath()
                            ctx.fill()

                            // Sound waves
                            ctx.beginPath()
                            ctx.arc(14, 11, 3.5, -0.7, 0.7)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.arc(14, 11, 6,   -0.7, 0.7)
                            ctx.stroke()
                        }
                    }

                    // Volume track
                    Item {
                        Layout.fillWidth: true
                        height: 6

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color: "#3c3836"
                        }
                        Rectangle {
                            anchors.left:   parent.left
                            anchors.top:    parent.top
                            anchors.bottom: parent.bottom
                            width:  parent.width * Math.min(root.sinkVolume, 1.5)
                            radius: 3
                            color:  root.sinkVolume > 1.0 ? "#fb4934"
                                  : root.sinkVolume > 0.95 ? "#fe8019"
                                  : "#fabd2f"
                            Behavior on width {
                                SmoothedAnimation { velocity: 600 }
                            }
                        }
                    }

                    // Percentage readout
                    Text {
                        text: Math.round(root.sinkVolume * 100) + "%"
                        color: "#ebdbb2"
                        font.pixelSize: 13
                        Layout.preferredWidth: 38
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
