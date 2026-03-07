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
                color: "#000000"

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
                        color: "#0a3300"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            implicitWidth: parent.width * root.sinkVolume
                            color: "#39ff14"
                        }
                    }
                }

                Canvas {
                    anchors.fill: parent
                    z: 100
                    enabled: false
                    Component.onCompleted: requestPaint()
                    onVisibleChanged: if (visible) requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = "rgba(57, 255, 20, 0.12)"
                        ctx.fillRect(0, 0, width, height)
                        ctx.fillStyle = "rgba(0, 0, 0, 0.45)"
                        for (var y = 0; y < height; y += 3)
                            ctx.fillRect(0, y, width, 1)
                    }
                }

                Canvas {
                    anchors.fill: parent
                    z: 101
                    enabled: false
                    Component.onCompleted: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = "#39ff14"
                        ctx.lineWidth = 1.5
                        var c = 10
                        var w = width - 1, h = height - 1

                        ctx.beginPath()
                        ctx.moveTo(0, c); ctx.lineTo(0, 0); ctx.lineTo(c, 0)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(w - c, 0); ctx.lineTo(w, 0); ctx.lineTo(w, c)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(0, h - c); ctx.lineTo(0, h); ctx.lineTo(c, h)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(w - c, h); ctx.lineTo(w, h); ctx.lineTo(w, h - c)
                        ctx.stroke()
                    }
                }
            }
        }
    }
}
