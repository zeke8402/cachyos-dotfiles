import QtQuick
import QtQuick.Layouts

Item {
    id: root
    signal toggleRequested()

    implicitWidth: 32
    implicitHeight: 22
    Layout.preferredWidth:  implicitWidth
    Layout.preferredHeight: implicitHeight

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 5
        color: ma.containsMouse ? "#504945" : "#3c3836"

        Behavior on color { ColorAnimation { duration: 100 } }

        // EQ / mixer icon — three horizontal lines with offset knobs
        Canvas {
            anchors.centerIn: parent
            width: 20
            height: 14
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.lineWidth = 1.5

                var lines = [
                    { y: 2,  kp: 0.25 },
                    { y: 7,  kp: 0.65 },
                    { y: 12, kp: 0.45 }
                ]

                for (var i = 0; i < lines.length; i++) {
                    var y  = lines[i].y
                    var kx = lines[i].kp * width

                    // Track line
                    ctx.strokeStyle = "#665c54"
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()

                    // Knob — dark fill punches through, light outline on top
                    ctx.beginPath()
                    ctx.arc(kx, y, 2.8, 0, Math.PI * 2)
                    ctx.fillStyle = "#3c3836"
                    ctx.fill()
                    ctx.strokeStyle = "#ebdbb2"
                    ctx.stroke()
                }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleRequested()
        }
    }
}
