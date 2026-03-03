import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: workspaceRow
    spacing: 4

    function toRoman(n) {
        const vals = [10, 9, 5, 4, 1]
        const syms = ["X", "IX", "V", "IV", "I"]
        let result = ""
        let num = n
        for (let i = 0; i < vals.length; i++) {
            while (num >= vals[i]) {
                result += syms[i]
                num -= vals[i]
            }
        }
        return result
    }

    Repeater {
        model: 10

        Item {
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            property bool isOccupied: ws !== undefined

            // Workspaces I-V always visible; VI-X only when they have windows
            visible: index < 5 || isOccupied

            readonly property int paddingX: 8
            readonly property int paddingY: 4

            implicitWidth: wsLabel.implicitWidth + (paddingX * 2)
            implicitHeight: wsLabel.implicitHeight + (paddingY * 2)

            Rectangle {
                anchors.fill: parent
                radius: 2
                color: isActive ? "#040f04" : "#000000"
                border.color: isActive ? "#39ff14" : (isOccupied ? "#1a7a1a" : "#0a3300")
                border.width: isActive ? 2 : 1
            }

            Text {
                id: wsLabel
                anchors.centerIn: parent
                text: workspaceRow.toRoman(index + 1)
                color: isActive ? "#39ff14" : (isOccupied ? "#1a7a1a" : "#0a3300")
                font {
                    pixelSize: 11
                    bold: true
                    family: "monospace"
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
