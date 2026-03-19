import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    Layout.fillWidth: true
    color: "transparent"
    border.color: Theme.accentMed
    border.width: 1
    implicitHeight: driveLayout.implicitHeight + 24

    // mount path → display label, populated from fstab
    property var labelMap: ({})
    property var drives: []

    FileView {
        id: fstabFile
        path: "/etc/fstab"
        preload: true
        blockLoading: true
    }

    function parseFstab() {
        var map = {}
        var lines = fstabFile.text().split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line || line.startsWith("#")) continue
            var parts = line.split(/\s+/)
            if (parts.length < 2) continue
            var device = parts[0]
            var mount  = parts[1]
            if (device.startsWith("LABEL=")) {
                map[mount] = device.substring(6)
            } else if (mount === "/") {
                map["/"] = "system"
            }
        }
        root.labelMap = map
    }

    Process {
        id: dfProcess
        command: ["df", "--output=target,pcent"]
        property string buffer: ""

        stdout: SplitParser {
            onRead: line => { dfProcess.buffer += line + "\n" }
        }

        onExited: {
            var result = []
            var lines  = buffer.split("\n")
            buffer = ""
            for (var i = 0; i < lines.length; i++) {
                var t = lines[i].trim()
                if (!t || t.startsWith("Mounted")) continue
                var parts = t.split(/\s+/)
                if (parts.length < 2) continue
                var mount = parts[0]
                var pct   = parseInt(parts[1].replace('%', ''))
                if (isNaN(pct)) continue
                if (!root.labelMap.hasOwnProperty(mount)) continue
                result.push({ label: root.labelMap[mount], mount: mount, pct: pct })
            }
            root.drives = result
        }
    }

    function refresh() {
        parseFstab()
        dfProcess.buffer = ""
        dfProcess.running = true
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()

    ColumnLayout {
        id: driveLayout
        anchors {
            left: parent.left; right: parent.right
            top: parent.top
            margins: 12
        }
        spacing: 8

        Text {
            text: "STORAGE"
            color: Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: 16
            font.letterSpacing: 2
        }

        Repeater {
            model: root.drives

            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: modelData.label
                        color: Theme.accentMed
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelData.pct + "%"
                        color: modelData.pct >= 90 ? Theme.warning : Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 15
                    }
                }

                Item {
                    Layout.fillWidth: true
                    height: 8

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.accentDim
                    }

                    Rectangle {
                        width: parent.width * (modelData.pct / 100)
                        height: parent.height
                        color: modelData.pct >= 90 ? Theme.warning : Theme.accent
                    }
                }
            }
        }
    }
}
