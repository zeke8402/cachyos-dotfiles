import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool settingsPanelOpen: false

    function toggleSettingsPanel() {
        settingsPanelOpen = !settingsPanelOpen
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

            SettingsButton {
                onToggleRequested: root.toggleSettingsPanel()
            }
        }
    }

    ClockWidget {
        anchors.centerIn: parent
    }
}
