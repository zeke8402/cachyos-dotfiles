import QtQuick

Text {
    id: root

    property date now: new Date()

    text: Qt.formatDateTime(now, "dddd MMMM d  HH:mm:ss").toUpperCase()
    color: "#39ff14"
    font.pixelSize: 13
    font.bold: true
    font.family: "monospace"
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
