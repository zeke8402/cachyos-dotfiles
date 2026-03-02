import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property QtObject theme
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
                color: isActive ? root.theme.accent : root.theme.panelSurface
                border.color: isActive ? root.theme.accentStrong : root.theme.panelBorder
                border.width: 1
            }

            Text {
                id: workspaceLabel
                anchors.centerIn: parent
                text: index + 1
                color: isActive ? root.theme.accentForeground : (ws ? root.theme.textPrimary : root.theme.textMuted)
                font { pixelSize: 12; bold: true }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
