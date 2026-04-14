import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: workspaceRow
    spacing: 5

    Repeater {
        model: 10

        Item {
            id: chip

            property var  ws:         Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive:   Hyprland.focusedWorkspace?.id === (index + 1)
            property bool isOccupied: ws !== undefined

            // Always show 1-5; show 6-10 only when occupied
            visible: index < 5 || isOccupied

            implicitWidth:  Math.max(28, wsLabel.implicitWidth + 18)
            implicitHeight: 24

            Rectangle {
                id: bg
                anchors.fill: parent
                radius: 6

                color: chip.isActive   ? "#fabd2f"
                     : hov.containsMouse ? "#504945"
                     : chip.isOccupied  ? "#3c3836"
                     : "transparent"

                border.color: chip.isActive ? "transparent"
                            : chip.isOccupied ? "transparent"
                            : "#3c3836"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Text {
                id: wsLabel
                anchors.centerIn: parent
                text:  (index + 1).toString()
                color: chip.isActive   ? "#1d2021"
                     : chip.isOccupied ? "#d5c4a1"
                     : "#665c54"
                font.family:    "Lexend"
                font.pixelSize: 13
                font.bold:      chip.isActive
            }

            MouseArea {
                id: hov
                anchors.fill:  parent
                hoverEnabled:  true
                cursorShape:   Qt.PointingHandCursor
                onClicked:     Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
