import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool volumePanelOpen: false

    function toggleVolumePanel() {
        volumePanelOpen = !volumePanelOpen
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        WorkspaceWidget {}

        Item { Layout.fillWidth: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            TrayWidget {}

            VolumeStatus {
                onToggleRequested: root.toggleVolumePanel()
            }
        }
    }

    ClockWidget {
        anchors.centerIn: parent
    }
}
