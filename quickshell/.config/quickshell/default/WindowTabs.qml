import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

Variants {
    id: root

    readonly property list<string> sanctioned: ["kitty", "dolphin", "fuzzel"]

    model: Hyprland.focusedWorkspace?.toplevels?.values ?? []

    PanelWindow {
        id: tab

        required property HyprlandToplevel modelData

        readonly property var ipc:       modelData.lastIpcObject
        readonly property string wclass: ipc["class"] ?? ""
        readonly property bool blessed:  root.sanctioned.indexOf(wclass) !== -1
        readonly property int winX:      (ipc["at"] ?? [0, 0])[0]
        readonly property int winY:      (ipc["at"] ?? [0, 0])[1]

        readonly property int tabH:     16
        readonly property int borderPx: 3

        visible: wclass !== "" && wclass !== "quickshell"

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        anchors.top:  true
        anchors.left: true
        margins.top:  Math.max(0, winY - tabH)
        margins.left: Math.max(0, winX - borderPx)

        implicitWidth:  tabLabel.implicitWidth + 14
        implicitHeight: tabH

        Rectangle {
            anchors.fill: parent
            color: tab.blessed ? "#39ff14" : "#cc4400"

            Text {
                id: tabLabel
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 7
                }
                text: tab.blessed ? tab.wclass.toUpperCase() : "HERESY"
                color: "#000000"
                font.family: "VT323"
                font.pixelSize: 13
                font.bold: true
            }
        }
    }
}
