import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

RowLayout {
    id: trayRoot
    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            required property SystemTrayItem modelData
            readonly property SystemTrayItem trayItem: modelData

            width: 22
            height: 22
            implicitWidth: width
            implicitHeight: height
            Layout.preferredWidth: width
            Layout.preferredHeight: height

            IconImage {
                id: trayIcon
                anchors.centerIn: parent
                source: trayItem.icon
                implicitSize: 18
                asynchronous: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: Theme.accent
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                onClicked: (mouse) => {
                    const pos = trayRoot.mapToItem(null, mouse.x, mouse.y)
                    const parentWindow = QsWindow.window

                    if (mouse.button === Qt.LeftButton) {
                        if (trayItem.onlyMenu || trayItem.hasMenu) {
                            if (parentWindow) {
                                trayItem.display(parentWindow, pos.x, pos.y + trayRoot.height)
                            }
                        } else {
                            trayItem.activate()
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        trayItem.secondaryActivate()
                    } else if (mouse.button === Qt.RightButton) {
                        if (trayItem.hasMenu && parentWindow) {
                            trayItem.display(parentWindow, pos.x, pos.y + trayRoot.height)
                        }
                    }
                }

                onWheel: (wheel) => {
                    trayItem.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }
}
