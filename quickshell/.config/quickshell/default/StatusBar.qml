import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property QtObject theme
    property bool volumePanelOpen: false

    function toggleVolumePanel() {
        volumePanelOpen = !volumePanelOpen
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8

        WorkspaceWidget {
            theme: root.theme
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            TrayWidget {}

            VolumeStatus {
                theme: root.theme
                onToggleRequested: root.toggleVolumePanel()
            }
        }
    }

    ClockWidget {
        theme: root.theme
        anchors.centerIn: parent
    }
}
