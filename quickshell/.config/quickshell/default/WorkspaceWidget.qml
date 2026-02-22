import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 6

    Repeater {
        model: 9

        Item {
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            readonly property int paddingX: 8
            readonly property int paddingY: 6

            implicitWidth: workspaceLabel.implicitWidth + (paddingX * 2)
            implicitHeight: workspaceLabel.implicitHeight + (paddingY * 2)

            Rectangle {
                anchors.fill: parent
                radius: 5
                color: isActive ? "#2f5f4a" : "#2a2d44"
                border.color: isActive ? "#6ee7b7" : "#3b4261"
                border.width: 1
            }

            Text {
                id: workspaceLabel
                anchors.centerIn: parent
                text: index + 1
                color: isActive ? "#d8ffef" : (ws ? "#c0caf5" : "#7a809a")
                font { pixelSize: 12; bold: true }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
