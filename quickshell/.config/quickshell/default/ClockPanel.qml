import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: clockPanel

    property bool open: false
    property real statusBarHeight: 0
    property real screenWidth: 0
    signal closeRequested()

    visible: _shown
    property bool _shown: false

    implicitWidth: 620
    implicitHeight: 318
    color: "#000000"

    anchors {
        top: true
        left: true
    }
    margins {
        top: statusBarHeight + 8
        left: (screenWidth - implicitWidth) / 2
    }

    // ── Calendar state ────────────────────────────────────────────────────
    property date displayMonth: new Date(new Date().getFullYear(), new Date().getMonth(), 1)

    readonly property int _year: displayMonth.getFullYear()
    readonly property int _month: displayMonth.getMonth()
    readonly property string monthLabel: Qt.formatDate(displayMonth, "MMMM yyyy").toUpperCase()

    property var calCells: {
        var y = _year, m = _month
        return _buildCells(y, m)
    }

    function _buildCells(y, m) {
        var today = new Date()
        var todayY = today.getFullYear()
        var todayM = today.getMonth()
        var todayD = today.getDate()

        var firstDay = new Date(y, m, 1)
        var startOffset = (firstDay.getDay() + 6) % 7
        var daysInMonth = new Date(y, m + 1, 0).getDate()
        var daysInPrevMonth = new Date(y, m, 0).getDate()

        var cells = []
        for (var i = 0; i < 42; i++) {
            var day, inMonth, isToday
            if (i < startOffset) {
                day = daysInPrevMonth - startOffset + i + 1
                inMonth = false
                isToday = false
            } else if (i < startOffset + daysInMonth) {
                day = i - startOffset + 1
                inMonth = true
                isToday = (todayY === y && todayM === m && todayD === day)
            } else {
                day = i - startOffset - daysInMonth + 1
                inMonth = false
                isToday = false
            }
            cells.push({ day: day, inMonth: inMonth, isToday: isToday })
        }
        return cells
    }

    function prevMonth() { displayMonth = new Date(_year, _month - 1, 1) }
    function nextMonth() { displayMonth = new Date(_year, _month + 1, 1) }

    // ── Neofetch ──────────────────────────────────────────────────────────
    property string neofetchOutput: ""

    Process {
        id: neofetchProc
        command: ["bash", "-c", "neofetch --off 2>/dev/null | sed 's/\\x1b\\[[0-9;]*[A-Za-z]//g; s/\\x1b(B//g; s/\\x0f//g'"]
        running: true
        stdout: SplitParser {
            onRead: data => clockPanel.neofetchOutput += data + "\n"
        }
    }

    // ── Open / close ──────────────────────────────────────────────────────
    onOpenChanged: {
        if (open) {
            content.y = -clockPanel.implicitHeight
            _shown = true
            slideIn.restart()
        } else {
            slideOut.restart()
        }
    }

    // ── Content ───────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        clip: true

        Item {
            id: content
            width: parent.width
            height: parent.height

            NumberAnimation {
                id: slideIn
                target: content
                property: "y"
                to: 0
                duration: 200
                easing.type: Easing.OutQuint
            }
            NumberAnimation {
                id: slideOut
                target: content
                property: "y"
                to: -clockPanel.implicitHeight
                duration: 160
                easing.type: Easing.InCubic
                onStopped: clockPanel._shown = false
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ── Calendar column ───────────────────────────────────────
                Item {
                    Layout.preferredWidth: 300
                    Layout.fillHeight: true

                    ColumnLayout {
                        id: calLayout
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 16
                        }
                        spacing: 6

                        // Month navigation
                        RowLayout {
                            Layout.fillWidth: true

                            Item {
                                width: 28; height: 28
                                Text {
                                    anchors.centerIn: parent
                                    text: "<"
                                    color: "#39ff14"
                                    font.pixelSize: 22
                                    font.family: "VT323"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: clockPanel.prevMonth()
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: clockPanel.monthLabel
                                color: "#39ff14"
                                font.pixelSize: 20
                                font.family: "VT323"
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Item { Layout.fillWidth: true }

                            Item {
                                width: 28; height: 28
                                Text {
                                    anchors.centerIn: parent
                                    text: ">"
                                    color: "#39ff14"
                                    font.pixelSize: 22
                                    font.family: "VT323"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: clockPanel.nextMonth()
                                }
                            }
                        }

                        // Day-of-week headers
                        Row {
                            Layout.fillWidth: true
                            Repeater {
                                model: ["MON","TUE","WED","THU","FRI","SAT","SUN"]
                                Text {
                                    width: calLayout.width / 7
                                    text: modelData
                                    color: "#1a7a1a"
                                    font.pixelSize: 15
                                    font.family: "VT323"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // Calendar grid
                        Item {
                            Layout.fillWidth: true
                            height: 32 * 6

                            Repeater {
                                model: clockPanel.calCells

                                delegate: Item {
                                    x: (index % 7) * (parent.width / 7)
                                    y: Math.floor(index / 7) * 32
                                    width: parent.width / 7
                                    height: 32

                                    Rectangle {
                                        visible: modelData.isToday
                                        anchors.centerIn: parent
                                        width: 26; height: 26
                                        color: "#040f04"
                                        border.color: "#39ff14"
                                        border.width: 1
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.day
                                        color: modelData.isToday ? "#39ff14"
                                             : modelData.inMonth ? "#1a7a1a"
                                             : "#0a3300"
                                        font.pixelSize: 18
                                        font.family: "VT323"
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Divider ───────────────────────────────────────────────
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 16
                    Layout.bottomMargin: 16
                    color: "#1a7a1a"
                }

                // ── Neofetch column ───────────────────────────────────────
                Item {
                    id: neofetchPane
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    property real scrollY: 0

                    Text {
                        id: neofetchText
                        x: 12
                        y: neofetchPane.scrollY + 10
                        width: parent.width - 24
                        text: clockPanel.neofetchOutput
                        color: "#39ff14"
                        font.pixelSize: 13
                        font.family: "VT323"
                        renderType: Text.NativeRendering
                        wrapMode: Text.NoWrap
                    }

                    MouseArea {
                        anchors.fill: parent
                        onWheel: wheel => {
                            var maxScroll = Math.min(0, neofetchPane.height - neofetchText.height - 20)
                            neofetchPane.scrollY = Math.max(
                                maxScroll,
                                Math.min(0, neofetchPane.scrollY + wheel.angleDelta.y / 3)
                            )
                        }
                    }
                }
            }

            // ── Scanlines ─────────────────────────────────────────────────
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
                    for (var y = 0; y < height; y += 3)
                        ctx.fillRect(0, y, width, 1)
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
}
