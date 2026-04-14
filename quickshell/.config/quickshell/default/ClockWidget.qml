import QtQuick

Item {
    id: root

    signal toggleRequested()

    property date now: new Date()

    implicitWidth:  label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(root.now, "dddd MMMM d  ·  HH:mm")
        color: "#d5c4a1"
        font.family:    "Lexend"
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.toggleRequested()
    }

    Timer {
        interval: 60000
        running:  true
        repeat:   true
        onTriggered: root.now = new Date()
    }
}
