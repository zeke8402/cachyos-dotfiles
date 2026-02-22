import Quickshell
import Quickshell.Services.Pipewire
import Quickshell._Window
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: volumeStatus
    signal toggleRequested()
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
        color: "#1f2335"
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

                var levels = volumeStatus.waveLevel
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
            onClicked: volumeStatus.toggleRequested()
        }
    }
}
