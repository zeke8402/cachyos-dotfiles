import QtQuick

Item {
    id: root

    signal toggleRequested()

    property date now: new Date()

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(root.now, "dddd MMMM d  HH:mm:ss")
        color: "#39ff14"
        font.pixelSize: 24
        font.family: "VT323"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleRequested()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
