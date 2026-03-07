import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "darktide_quotes.js" as DarktideQuotes
import "config.js" as Config

PanelWindow {
    id: settingsPanel

    property bool open: false
    property real statusBarHeight: 0
    signal closeRequested()

    // Visibility is managed manually so we can delay hide until close animation finishes
    visible: _shown
    property bool _shown: false

    implicitWidth: 500
    implicitHeight: 780
    color: "#000000"

    onOpenChanged: {
        if (open) {
            content.x = settingsPanel.implicitWidth  // start off-screen right
            _shown = true
            slideIn.restart()
        } else {
            slideOut.restart()
        }
    }

    readonly property PwNode sinkNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink : null
    readonly property PwNode sourceNode: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource : null
    readonly property real sinkVolume: sinkNode && sinkNode.audio ? sinkNode.audio.volume : 0
    readonly property real sourceVolume: sourceNode && sourceNode.audio ? sourceNode.audio.volume : 0

    property int quoteIndex: 0
    readonly property var quotes: DarktideQuotes.quotes

    onVisibleChanged: {
        if (visible) quoteIndex = Math.floor(Math.random() * quotes.length)
    }

    anchors {
        top: true
        right: true
    }
    margins {
        top: statusBarHeight + 8
        right: 16
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].filter(n => n)
    }

    function setSinkVolume(v: real) {
        if (sinkNode && sinkNode.audio) sinkNode.audio.volume = v
    }
    function setSourceVolume(v: real) {
        if (sourceNode && sourceNode.audio) sourceNode.audio.volume = v
    }

    // ── Animated content wrapper ──────────────────────────────────────────
    Item {
        id: content
        width: parent.width
        height: parent.height

        NumberAnimation {
            id: slideIn
            target: content
            property: "x"
            to: 0
            duration: 220
            easing.type: Easing.OutQuint
        }

        NumberAnimation {
            id: slideOut
            target: content
            property: "x"
            to: settingsPanel.implicitWidth
            duration: 180
            easing.type: Easing.InCubic
            onStopped: settingsPanel._shown = false
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // ── AM Logo ───────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                implicitHeight: amLogo.implicitHeight + 8

                FileView {
                    id: logoFile
                    path: Qt.resolvedUrl("am_logo.txt").toString().replace("file://", "")
                    blockLoading: true
                    preload: true
                }

                Text {
                    id: amLogo
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    text: logoFile.text()

                    color: "#39ff14"
                    font.family: "VT323"
                    font.pixelSize: 6
                    font.kerning: false
                    renderType: Text.NativeRendering
                }
            }

            // ── Quote widget ──────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                height: Math.max(64, quoteText.contentHeight + 28)

                Canvas {
                    id: quoteCorners
                    anchors.fill: parent
                    onWidthChanged:  requestPaint()
                    onHeightChanged: requestPaint()
                    Component.onCompleted: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = "#39ff14"
                        ctx.lineWidth = 1
                        var c = 12
                        var w = width - 1, h = height - 1

                        ctx.beginPath()
                        ctx.moveTo(0, c); ctx.lineTo(0, 0); ctx.lineTo(c, 0)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(w - c, 0); ctx.lineTo(w, 0); ctx.lineTo(w, c)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(0, h - c); ctx.lineTo(0, h); ctx.lineTo(c, h)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(w - c, h); ctx.lineTo(w, h); ctx.lineTo(w, h - c)
                        ctx.stroke()
                    }
                }

                Text {
                    id: quoteText
                    x: 14
                    y: 14
                    width: parent.width - 28
                    text: settingsPanel.quotes[settingsPanel.quoteIndex]
                    color: "#1a7a1a"
                    font.pixelSize: 21
                    font.family: "VT323"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // ── Volume section ────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                color: "transparent"
                border.color: "#1a7a1a"
                border.width: 1
                implicitHeight: volLayout.implicitHeight + 24

                ColumnLayout {
                    id: volLayout
                    anchors {
                        left: parent.left; right: parent.right
                        top: parent.top
                        margins: 12
                    }
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "OUT"
                            color: "#39ff14"
                            font.pixelSize: 18
                            font.family: "VT323"
                            width: 28
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Item {
                            id: sinkSliderItem
                            Layout.fillWidth: true
                            height: 20
                            property real sliderValue: settingsPanel.sinkVolume

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 4
                                radius: 2
                                color: "#0a3300"
                                Rectangle {
                                    width: parent.width * sinkSliderItem.sliderValue
                                    height: parent.height
                                    radius: parent.radius
                                    color: "#39ff14"
                                }
                            }
                            Rectangle {
                                x: sinkSliderItem.sliderValue * (parent.width - width)
                                anchors.verticalCenter: parent.verticalCenter
                                width: 10
                                height: 10
                                radius: 5
                                color: "#39ff14"
                            }
                            MouseArea {
                                id: sinkMA
                                anchors.fill: parent
                                function applyX(mx) {
                                    var v = Math.max(0, Math.min(1, mx / width))
                                    sinkSliderItem.sliderValue = v
                                    settingsPanel.setSinkVolume(v)
                                }
                                onPressed: (mouse) => applyX(mouse.x)
                                onPositionChanged: (mouse) => applyX(mouse.x)
                            }
                            Connections {
                                target: settingsPanel
                                function onSinkVolumeChanged() {
                                    if (!sinkMA.pressed) sinkSliderItem.sliderValue = settingsPanel.sinkVolume
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "IN"
                            color: "#39ff14"
                            font.pixelSize: 18
                            font.family: "VT323"
                            width: 28
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Item {
                            id: sourceSliderItem
                            Layout.fillWidth: true
                            height: 20
                            property real sliderValue: settingsPanel.sourceVolume

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 4
                                radius: 2
                                color: "#0a3300"
                                Rectangle {
                                    width: parent.width * sourceSliderItem.sliderValue
                                    height: parent.height
                                    radius: parent.radius
                                    color: "#39ff14"
                                }
                            }
                            Rectangle {
                                x: sourceSliderItem.sliderValue * (parent.width - width)
                                anchors.verticalCenter: parent.verticalCenter
                                width: 10
                                height: 10
                                radius: 5
                                color: "#39ff14"
                            }
                            MouseArea {
                                id: sourceMA
                                anchors.fill: parent
                                function applyX(mx) {
                                    var v = Math.max(0, Math.min(1, mx / width))
                                    sourceSliderItem.sliderValue = v
                                    settingsPanel.setSourceVolume(v)
                                }
                                onPressed: (mouse) => applyX(mouse.x)
                                onPositionChanged: (mouse) => applyX(mouse.x)
                            }
                            Connections {
                                target: settingsPanel
                                function onSourceVolumeChanged() {
                                    if (!sourceMA.pressed) sourceSliderItem.sliderValue = settingsPanel.sourceVolume
                                }
                            }
                        }
                    }

                    // ── Output device selector ────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        readonly property string activeSink: settingsPanel.sinkNode ? settingsPanel.sinkNode.name : ""

                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            color: parent.activeSink === Config.speakerSink ? "#39ff14" : "#000000"
                            border.color: "#39ff14"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "SPEAKERS"
                                color: parent.parent.activeSink === Config.speakerSink ? "#000000" : "#39ff14"
                                font.pixelSize: 17
                                font.family: "VT323"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["pactl", "set-default-sink", Config.speakerSink])
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            color: parent.activeSink === Config.headsetSink ? "#39ff14" : "#000000"
                            border.color: "#39ff14"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "HEADSET"
                                color: parent.parent.activeSink === Config.headsetSink ? "#000000" : "#39ff14"
                                font.pixelSize: 17
                                font.family: "VT323"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["pactl", "set-default-sink", Config.headsetSink])
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 32
                        color: "#39ff14"
                        border.color: "#0a3300"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "OPEN VOXCASTER"
                            color: "#000000"
                            font.pixelSize: 17
                            font.family: "VT323"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsPanel.closeRequested()
                                Quickshell.execDetached(["pavucontrol"])
                            }
                        }
                    }
                }
            }

            // ── Drive space ───────────────────────────────────────────────
            DriveSpace {}

            // ── Space for future widgets ──────────────────────────────────
            Item { Layout.fillHeight: true }
        }

        // Green phosphor scanlines
        Canvas {
            anchors.fill: parent
            z: 100
            enabled: false
            Component.onCompleted: requestPaint()
            onVisibleChanged: if (visible) requestPaint()
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

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#1a7a1a"
            border.width: 1
            z: 101
            enabled: false
        }
    }
}
