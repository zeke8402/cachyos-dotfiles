import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

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
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#dd000000"
                border.color: "#1a7a1a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 15

                    Canvas {
                        id: speakerIcon
                        implicitWidth: 30
                        implicitHeight: 30
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.fillStyle = "#39ff14"
                            ctx.strokeStyle = "#39ff14"
                            ctx.lineWidth = 2.2

                            var bx = 4
                            var by = 11
                            var bw = 6
                            var bh = 8
                            var mx = bx + bw
                            var cy = by + bh / 2

                            ctx.beginPath()
                            ctx.rect(bx, by, bw, bh)
                            ctx.fill()

                            ctx.beginPath()
                            ctx.moveTo(mx, by - 2)
                            ctx.lineTo(mx + 7, by - 5)
                            ctx.lineTo(mx + 7, by + bh + 5)
                            ctx.lineTo(mx, by + bh + 2)
                            ctx.closePath()
                            ctx.fill()

                            ctx.beginPath()
                            ctx.arc(mx + 7, cy, 5, -0.7, 0.7)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.arc(mx + 7, cy, 8, -0.7, 0.7)
                            ctx.stroke()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: "#0a3300"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            implicitWidth: parent.width * root.sinkVolume
                            radius: parent.radius
                            color: "#39ff14"
                        }
                    }
                }
            }
        }
    }
}
