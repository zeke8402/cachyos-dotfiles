import QtQuick

Text {
    id: root

    property date now: new Date()

    text: Qt.formatDateTime(now, "dddd MMMM d  HH:mm:ss")
    color: "#39ff14"
    font.pixelSize: 24
    font.family: "VT323"
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
