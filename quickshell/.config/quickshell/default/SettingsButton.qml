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
        color: "#000000"
        border.color: "#1a7a1a"
        border.width: 1

        Canvas {
            anchors.centerIn: parent
            width: 22
            height: 16
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#39ff14"
                ctx.fillStyle = "#39ff14"
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

                    // Knob: black fill punches through the line, green outline on top
                    ctx.beginPath()
                    ctx.arc(kx, y, 2.5, 0, Math.PI * 2)
                    ctx.fillStyle = "#000000"
                    ctx.fill()
                    ctx.strokeStyle = "#39ff14"
                    ctx.stroke()
                    ctx.fillStyle  = "#39ff14"
                    ctx.strokeStyle = "#39ff14"
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.toggleRequested()
        }
    }
}
