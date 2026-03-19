import QtQuick
import QtQuick.Layouts

Item {
    id: root
    signal toggleRequested()

    implicitWidth: 34
    implicitHeight: 22
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: 2
        color: Theme.background
        border.color: Theme.accentMed
        border.width: 1

        Canvas {
            anchors.centerIn: parent
            width: 22
            height: 16
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = Theme.accent.toString()
                ctx.fillStyle   = Theme.accent.toString()
                ctx.lineWidth = 1.5

                var lines = [
                    { y: 3,  kp: 0.28 },
                    { y: 8,  kp: 0.68 },
                    { y: 13, kp: 0.48 }
                ]
                for (var i = 0; i < lines.length; i++) {
                    var y  = lines[i].y
                    var kx = lines[i].kp * width

                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.arc(kx, y, 2.5, 0, Math.PI * 2)
                    ctx.fillStyle = Theme.background.toString()
                    ctx.fill()
                    ctx.strokeStyle = Theme.accent.toString()
                    ctx.stroke()
                    ctx.fillStyle   = Theme.accent.toString()
                    ctx.strokeStyle = Theme.accent.toString()
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.toggleRequested()
        }
    }
}
