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

    QtObject {
        id: shellState
        property bool settingsPanelOpen: false
        property bool clockPanelOpen: false
        property bool themeSwitcherOpen: false
    }

    // ── IPC handler — allows `qs ipc call default themeToggle` from hyprland
    IpcHandler {
        target: "themeToggle"
        function onMessage(message: string, reply: var) {
            shellState.themeSwitcherOpen = !shellState.themeSwitcherOpen
            reply("")
        }
    }

    Variants {
        model: Quickshell.screens

        WlrLayershell {
            required property var modelData
            screen: modelData
            layer: WlrLayer.Top
            namespace: "quickshell"
            keyboardFocus: WlrKeyboardFocus.None
            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 40
            color: Theme.background

            StatusBar {
                anchors.fill: parent
                onSettingsToggleRequested: shellState.settingsPanelOpen = !shellState.settingsPanelOpen
                onClockToggleRequested: shellState.clockPanelOpen = !shellState.clockPanelOpen
            }

            // Scanline overlay — simulates CRT phosphor artifacts
            Canvas {
                id: statusBarScanlines
                anchors.fill: parent
                z: 100
                enabled: false
                visible: Theme.scanlines

                Connections {
                    target: Theme
                    function onThemeApplied() { statusBarScanlines.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var r = Math.round(Theme.accent.r * 255)
                    var g = Math.round(Theme.accent.g * 255)
                    var b = Math.round(Theme.accent.b * 255)
                    ctx.fillStyle = "rgba(" + r + "," + g + "," + b + ",0.06)"
                    ctx.fillRect(0, 0, width, height)
                    ctx.fillStyle = "rgba(0,0,0,0.28)"
                    for (var y = 0; y < height; y += 3)
                        ctx.fillRect(0, y, width, 1)
                }
            }
        }
    }

    SettingsPanel {
        id: settingsPanel
        open: shellState.settingsPanelOpen
        statusBarHeight: 40
        onCloseRequested: shellState.settingsPanelOpen = false
    }

    HyprlandFocusGrab {
        active: shellState.settingsPanelOpen
        windows: [settingsPanel]
        onCleared: shellState.settingsPanelOpen = false
    }

    ClockPanel {
        id: clockPanel
        open: shellState.clockPanelOpen
        statusBarHeight: 40
        screenWidth: Quickshell.screens.length > 0 ? Quickshell.screens[0].width : 1920
        onCloseRequested: shellState.clockPanelOpen = false
    }

    HyprlandFocusGrab {
        active: shellState.clockPanelOpen
        windows: [clockPanel]
        onCleared: shellState.clockPanelOpen = false
    }

    ThemeSwitcher {
        id: themeSwitcher
        open: shellState.themeSwitcherOpen
        onCloseRequested: shellState.themeSwitcherOpen = false
    }

    HyprlandFocusGrab {
        active: shellState.themeSwitcherOpen
        windows: [themeSwitcher]
        onCleared: shellState.themeSwitcherOpen = false
    }

    VolumeOsd {}
}
