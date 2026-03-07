//@ pragma IconTheme Papirus
//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Wayland._WlrLayerShell
import Quickshell.Hyprland
import QtQuick

Scope {
    FontLoader { source: "fonts/First Legion.ttf" }
    FontLoader { source: "fonts/VT323-Regular.ttf" }

    WlrLayershell {
        layer: WlrLayer.Top
        namespace: "quickshell"
        keyboardFocus: WlrKeyboardFocus.None
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 40
        color: "#000000"

        StatusBar {
            id: statusBar
            anchors.fill: parent
        }

        // Scanline overlay — simulates phosphor CRT screen artifacts
        Canvas {
            anchors.fill: parent
            z: 100
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = "rgba(57, 255, 20, 0.06)"
                ctx.fillRect(0, 0, width, height)
                ctx.fillStyle = "rgba(0, 0, 0, 0.28)"
                for (var y = 0; y < height; y += 3) {
                    ctx.fillRect(0, y, width, 1)
                }
            }
        }
    }

    SettingsPanel {
        id: settingsPanel
        open: statusBar.settingsPanelOpen
        statusBarHeight: statusBar.height
        onCloseRequested: statusBar.settingsPanelOpen = false
    }

    HyprlandFocusGrab {
        active: statusBar.settingsPanelOpen
        windows: [settingsPanel]
        onCleared: statusBar.settingsPanelOpen = false
    }

    ClockPanel {
        id: clockPanel
        open: statusBar.clockPanelOpen
        statusBarHeight: statusBar.height
        screenWidth: statusBar.width
        onCloseRequested: statusBar.clockPanelOpen = false
    }

    HyprlandFocusGrab {
        active: statusBar.clockPanelOpen
        windows: [clockPanel]
        onCleared: statusBar.clockPanelOpen = false
    }

    VolumeOsd {}
    WindowTabs {}
}
