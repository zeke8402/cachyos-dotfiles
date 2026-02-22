import QtQuick

Text {
    id: root

    property date now: new Date()

    text: Qt.formatDateTime(now, "ddd MMM d  HH:mm:ss")
    color: "#c0caf5"
    font.pixelSize: 13
    font.bold: true
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
