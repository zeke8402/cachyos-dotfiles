import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false
    width: 0
    height: 0

    property color background: "#1a1b26"
    property color foreground: "#c0caf5"
    property color cursor: "#c0caf5"
    property color color0: "#15161e"
    property color color1: "#f7768e"
    property color color2: "#9ece6a"
    property color color3: "#e0af68"
    property color color4: "#7aa2f7"
    property color color5: "#bb9af7"
    property color color6: "#7dcfff"
    property color color7: "#a9b1d6"
    property color color8: "#414868"
    property color color9: "#f7768e"
    property color color10: "#9ece6a"
    property color color11: "#e0af68"
    property color color12: "#7aa2f7"
    property color color13: "#bb9af7"
    property color color14: "#7dcfff"
    property color color15: "#c0caf5"
    readonly property color barBackground: background
    readonly property color panelBackground: color0
    readonly property color panelSurface: withAlpha(color8, 0.22)
    readonly property color panelBorder: withAlpha(foreground, 0.18)
    readonly property color textPrimary: foreground
    readonly property color textMuted: withAlpha(foreground, 0.58)
    readonly property color accent: color2
    readonly property color accentStrong: color10
    readonly property color accentForeground: background
    readonly property color overlayBackground: withAlpha(background, 0.82)
    readonly property color overlayTrack: withAlpha(foreground, 0.32)

    function withAlpha(value, alpha) {
        const hex = value.toString().replace("#", "")
        const rgb = hex.length >= 6 ? hex.slice(hex.length - 6) : "000000"
        const a = Math.max(0, Math.min(255, Math.round(alpha * 255)))
        return "#" + a.toString(16).padStart(2, "0") + rgb
    }

    FileView {
        id: wallustColors
        path: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/wallust/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onTextChanged: {
            const content = String(wallustColors.text() || "").trim()
            if (!content) return
            if (!content.startsWith("{") || !content.endsWith("}")) return
            try {
                const d = JSON.parse(content)
                if (d.background) root.background = d.background
                if (d.foreground) root.foreground = d.foreground
                if (d.cursor) root.cursor = d.cursor
                if (d.color0) root.color0 = d.color0
                if (d.color1) root.color1 = d.color1
                if (d.color2) root.color2 = d.color2
                if (d.color3) root.color3 = d.color3
                if (d.color4) root.color4 = d.color4
                if (d.color5) root.color5 = d.color5
                if (d.color6) root.color6 = d.color6
                if (d.color7) root.color7 = d.color7
                if (d.color8) root.color8 = d.color8
                if (d.color9) root.color9 = d.color9
                if (d.color10) root.color10 = d.color10
                if (d.color11) root.color11 = d.color11
                if (d.color12) root.color12 = d.color12
                if (d.color13) root.color13 = d.color13
                if (d.color14) root.color14 = d.color14
                if (d.color15) root.color15 = d.color15
            } catch (e) {
            }
        }
    }
}
