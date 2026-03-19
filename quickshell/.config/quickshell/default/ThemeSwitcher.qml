import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: switcher

    property bool open: false
    signal closeRequested()

    visible: _shown
    property bool _shown: false
    property int selectedIndex: 0

    // ── Theme manifest ────────────────────────────────────────────────────
    // Add new themes here. Colors are used for the live card preview only;
    // the full JSON lives in themes/<id>/theme.json and is applied by
    // theme-apply.sh for non-QML consumers (kitty, hyprland borders, etc.)
    readonly property var themes: [
        {
            id: "cogitator",
            name: "COGITATOR MK.VII",
            lore: "Adeptus Mechanicus standard-issue cogitation array",
            colors: {
                accent:     "#39ff14",
                accentMed:  "#1a7a1a",
                accentDim:  "#0a3300",
                accentBg:   "#040f04",
                background: "#000000",
                warning:    "#cc4400",
                warningDim: "#3a1000"
            },
            fonts: { display: "First Legion", mono: "VT323" },
            effects: { scanlines: true, tacbracks: true }
        },
        {
            id: "nier",
            name: "YORHA UNIT",
            lore: "Glory to mankind. Tactical android interface protocol",
            colors: {
                accent:     "#c8b89a",
                accentMed:  "#8b7d6b",
                accentDim:  "#3d3530",
                accentBg:   "#15120e",
                background: "#0a0a08",
                warning:    "#e8c84a",
                warningDim: "#6b5a20"
            },
            fonts: { display: "VT323", mono: "VT323" },
            effects: { scanlines: false, tacbracks: true }
        }
    ]

    // ── Window geometry ───────────────────────────────────────────────────
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    exclusiveZone: -1
    color: "transparent"
    mask: Region {}

    // ── Open/close animation ──────────────────────────────────────────────
    onOpenChanged: {
        if (open) {
            // Snap selected index to current theme
            for (var i = 0; i < themes.length; i++) {
                if (themes[i].id === Theme.currentThemeId) {
                    selectedIndex = i
                    break
                }
            }
            overlay.opacity = 0
            _shown = true
            fadeIn.restart()
        } else {
            fadeOut.restart()
        }
    }

    // ── Backdrop ──────────────────────────────────────────────────────────
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "#b0000000"
        opacity: 0

        NumberAnimation { id: fadeIn;  target: overlay; property: "opacity"; to: 1;  duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { id: fadeOut; target: overlay; property: "opacity"; to: 0;  duration: 140; easing.type: Easing.InCubic;
            onStopped: switcher._shown = false }

        MouseArea {
            anchors.fill: parent
            onClicked: switcher.closeRequested()
        }
    }

    // ── Central card strip ────────────────────────────────────────────────
    Item {
        anchors.centerIn: parent
        width: parent.width
        height: 260

        // Title
        Text {
            id: titleText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: "// SELECT PROFILE //"
            color: Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: 22
            font.letterSpacing: 4
        }

        // Lore line
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: titleText.bottom
            anchors.topMargin: 4
            text: switcher.themes[switcher.selectedIndex].lore
            color: Theme.accentMed
            font.family: Theme.fontMono
            font.pixelSize: 15
            opacity: 0.8
        }

        // Cards row
        Row {
            id: cardsRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            spacing: -18  // cards overlap slightly due to slant

            Repeater {
                model: switcher.themes

                Item {
                    id: card
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: switcher.selectedIndex === index
                    readonly property var td: modelData  // theme data shorthand

                    width: 210
                    height: 160

                    // Parallelogram canvas background
                    Canvas {
                        id: cardCanvas
                        anchors.fill: parent
                        readonly property int skew: 22

                        Connections {
                            target: switcher
                            function onSelectedIndexChanged() { cardCanvas.requestPaint() }
                        }
                        Connections {
                            target: Theme
                            function onThemeApplied() { cardCanvas.requestPaint() }
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var s = skew

                            // Fill
                            ctx.beginPath()
                            ctx.moveTo(s, 0)
                            ctx.lineTo(width, 0)
                            ctx.lineTo(width - s, height)
                            ctx.lineTo(0, height)
                            ctx.closePath()
                            ctx.fillStyle = card.td.colors.background
                            ctx.fill()

                            // Border
                            ctx.strokeStyle = card.isSelected ? card.td.colors.accent : card.td.colors.accentMed
                            ctx.lineWidth   = card.isSelected ? 2.5 : 1
                            ctx.stroke()

                            // Inner glow strip on selected
                            if (card.isSelected) {
                                ctx.beginPath()
                                ctx.moveTo(s + 3, 3)
                                ctx.lineTo(width - 3, 3)
                                ctx.lineTo(width - s - 3, height - 3)
                                ctx.lineTo(3, height - 3)
                                ctx.closePath()
                                var r = parseInt(card.td.colors.accent.substring(1,3), 16)
                                var g = parseInt(card.td.colors.accent.substring(3,5), 16)
                                var b = parseInt(card.td.colors.accent.substring(5,7), 16)
                                ctx.strokeStyle = "rgba(" + r + "," + g + "," + b + ",0.18)"
                                ctx.lineWidth = 6
                                ctx.stroke()
                            }
                        }
                    }

                    // Color swatch preview — mini palette strip
                    Item {
                        x: cardCanvas.skew + 10
                        y: 16
                        width: parent.width - cardCanvas.skew * 2 - 20
                        height: 72

                        // Background swatch
                        Rectangle {
                            anchors.fill: parent
                            color: card.td.colors.background
                            border.color: card.td.colors.accentDim
                            border.width: 1
                        }

                        // Simulated status bar
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 14
                            color: card.td.colors.accentBg

                            // Workspace dots
                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                spacing: 3
                                Repeater {
                                    model: 5
                                    Rectangle {
                                        width: 8; height: 8
                                        color: "transparent"
                                        border.color: index === 0 ? card.td.colors.accent : card.td.colors.accentMed
                                        border.width: 1
                                    }
                                }
                            }

                            // Clock placeholder bar
                            Rectangle {
                                anchors.centerIn: parent
                                width: 40; height: 6
                                color: card.td.colors.accent
                                opacity: 0.7
                            }
                        }

                        // Palette swatches row
                        Row {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 6
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4

                            Repeater {
                                model: [
                                    card.td.colors.accent,
                                    card.td.colors.accentMed,
                                    card.td.colors.accentDim,
                                    card.td.colors.warning,
                                    card.td.colors.background
                                ]
                                Rectangle {
                                    width: 14; height: 14
                                    color: modelData
                                    border.color: card.td.colors.accentMed
                                    border.width: 1
                                }
                            }
                        }
                    }

                    // Theme name
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 0
                        text: card.td.name
                        color: card.isSelected ? card.td.colors.accent : card.td.colors.accentMed
                        font.family: Theme.fontMono
                        font.pixelSize: 14
                        font.letterSpacing: 2
                    }

                    // Selection indicator dot
                    Rectangle {
                        visible: card.isSelected
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 6; height: 6; radius: 3
                        color: card.td.colors.accent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: switcher.selectedIndex = card.index
                        onDoubleClicked: switcher._applySelected()
                        cursorShape: Qt.PointingHandCursor
                    }

                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                    scale: card.isSelected ? 1.04 : 1.0
                }
            }
        }

        // ── Arrow hints ───────────────────────────────────────────────────
        Text {
            anchors.left: cardsRow.left
            anchors.leftMargin: -32
            anchors.verticalCenter: cardsRow.verticalCenter
            text: "◀"
            color: Theme.accentMed
            font.family: Theme.fontMono
            font.pixelSize: 20
            opacity: switcher.selectedIndex > 0 ? 1 : 0.15
        }

        Text {
            anchors.right: cardsRow.right
            anchors.rightMargin: -32
            anchors.verticalCenter: cardsRow.verticalCenter
            text: "▶"
            color: Theme.accentMed
            font.family: Theme.fontMono
            font.pixelSize: 20
            opacity: switcher.selectedIndex < switcher.themes.length - 1 ? 1 : 0.15
        }

        // ── Key hint footer ───────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: "[ ← → ] NAVIGATE    [ ENTER ] APPLY    [ ESC ] CANCEL"
            color: Theme.accentDim
            font.family: Theme.fontMono
            font.pixelSize: 13
            font.letterSpacing: 1
        }
    }

    // ── Keyboard handling ─────────────────────────────────────────────────
    Keys.onPressed: (event) => {
        if (!switcher.open) return
        if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
            if (switcher.selectedIndex > 0) switcher.selectedIndex--
            event.accepted = true
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
            if (switcher.selectedIndex < switcher.themes.length - 1) switcher.selectedIndex++
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            switcher._applySelected()
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            switcher.closeRequested()
            event.accepted = true
        }
    }

    // ── Apply the selected theme ──────────────────────────────────────────
    function _applySelected() {
        var td = themes[selectedIndex]

        // Update the QML singleton immediately — everything repaints
        Theme.applyTheme(td)

        // Run the external script for kitty, hyprland borders, wallpaper
        Quickshell.execDetached([
            "bash",
            Qt.resolvedUrl("../../../../../scripts/theme-apply.sh").toString().replace("file://", ""),
            td.id
        ])

        switcher.closeRequested()
    }
}
