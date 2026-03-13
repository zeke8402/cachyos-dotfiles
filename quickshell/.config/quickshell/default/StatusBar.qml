import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    signal settingsToggleRequested()
    signal clockToggleRequested()

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
                onToggleRequested: root.settingsToggleRequested()
            }
        }
    }

    ClockWidget {
        anchors.centerIn: parent
        onToggleRequested: root.clockToggleRequested()
    }
}
