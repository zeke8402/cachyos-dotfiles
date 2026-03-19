pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // ── Current theme id ──────────────────────────────────────────────────
    property string currentThemeId: "cogitator"

    // ── Color palette (defaults = cogitator) ─────────────────────────────
    property color accent:     "#39ff14"
    property color accentMed:  "#1a7a1a"
    property color accentDim:  "#0a3300"
    property color accentBg:   "#040f04"
    property color background: "#000000"
    property color warning:    "#cc4400"
    property color warningDim: "#3a1000"

    // ── Typography ────────────────────────────────────────────────────────
    property string fontDisplay: "First Legion"
    property string fontMono:    "VT323"

    // ── Effects ───────────────────────────────────────────────────────────
    property bool scanlines: true
    property bool tacbracks: true

    // ── Load persisted theme on startup ───────────────────────────────────
    property string _loadBuf: ""

    property var _loader: Process {
        command: ["sh", "-c", "cat ~/.config/theme/active.json 2>/dev/null"]
        running: true
        stdout: SplitParser {
            onRead: data => root._loadBuf += data + "\n"
        }
        onExited: {
            try {
                var d = JSON.parse(root._loadBuf.trim())
                if (d && d.colors) root._applyData(d)
            } catch (e) {}
        }
    }

    // ── Apply a theme data object (called by ThemeSwitcher) ───────────────
    function applyTheme(data) {
        _applyData(data)
    }

    // Fired after any theme switch — Canvases connect to this to repaint
    signal themeApplied()

    function _applyData(data) {
        if (!data || !data.colors) return
        var c = data.colors
        if (c.accent)     accent     = c.accent
        if (c.accentMed)  accentMed  = c.accentMed
        if (c.accentDim)  accentDim  = c.accentDim
        if (c.accentBg)   accentBg   = c.accentBg
        if (c.background) background = c.background
        if (c.warning)    warning    = c.warning
        if (c.warningDim) warningDim = c.warningDim
        if (data.fonts) {
            if (data.fonts.display) fontDisplay = data.fonts.display
            if (data.fonts.mono)    fontMono    = data.fonts.mono
        }
        if (data.effects) {
            scanlines = data.effects.scanlines !== false
            tacbracks = data.effects.tacbracks !== false
        }
        if (data.id) currentThemeId = data.id
        themeApplied()
    }
}
