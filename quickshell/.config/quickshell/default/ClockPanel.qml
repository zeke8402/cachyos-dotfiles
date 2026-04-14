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

    implicitWidth:  620
    implicitHeight: 272
    color: "#1d2021"

    anchors {
        top:  true
        left: true
    }
    margins {
        top:  statusBarHeight + 8
        left: (screenWidth - implicitWidth) / 2
    }

    // ── Calendar state ────────────────────────────────────────────────────
    property date displayMonth: new Date(new Date().getFullYear(), new Date().getMonth(), 1)

    readonly property int    _year:      displayMonth.getFullYear()
    readonly property int    _month:     displayMonth.getMonth()
    readonly property string monthLabel: Qt.formatDate(displayMonth, "MMMM yyyy")

    property var calCells: _buildCells(_year, _month)

    function _buildCells(y, m) {
        var today  = new Date()
        var todayY = today.getFullYear()
        var todayM = today.getMonth()
        var todayD = today.getDate()

        var firstDay      = new Date(y, m, 1)
        var startOffset   = (firstDay.getDay() + 6) % 7
        var daysInMonth   = new Date(y, m + 1, 0).getDate()
        var daysInPrevMon = new Date(y, m,     0).getDate()

        var cells = []
        for (var i = 0; i < 42; i++) {
            var day, inMonth, isToday
            if (i < startOffset) {
                day     = daysInPrevMon - startOffset + i + 1
                inMonth = false
                isToday = false
            } else if (i < startOffset + daysInMonth) {
                day     = i - startOffset + 1
                inMonth = true
                isToday = (todayY === y && todayM === m && todayD === day)
            } else {
                day     = i - startOffset - daysInMonth + 1
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
            width:  parent.width
            height: parent.height

            NumberAnimation {
                id: slideIn
                target:   content
                property: "y"
                to:       0
                duration: 200
                easing.type: Easing.OutQuint
            }
            NumberAnimation {
                id: slideOut
                target:   content
                property: "y"
                to:       -clockPanel.implicitHeight
                duration: 160
                easing.type: Easing.InCubic
                onStopped: clockPanel._shown = false
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ── Calendar column ───────────────────────────────────────
                Item {
                    Layout.preferredWidth: 290
                    Layout.fillHeight: true

                    ColumnLayout {
                        id: calLayout
                        anchors {
                            left:    parent.left
                            right:   parent.right
                            top:     parent.top
                            margins: 16
                        }
                        spacing: 8

                        // ── Month navigation ──────────────────────────────
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            // Prev button
                            Rectangle {
                                width: 24; height: 24
                                radius: 6
                                color: prevMa.containsMouse ? "#504945" : "#3c3836"
                                Behavior on color { ColorAnimation { duration: 80 } }
                                Text {
                                    anchors.centerIn: parent
                                    text:  "‹"
                                    color: "#ebdbb2"
                                    font.pixelSize: 16
                                }
                                MouseArea {
                                    id: prevMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    clockPanel.prevMonth()
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text:  clockPanel.monthLabel
                                color: "#ebdbb2"
                                font.family:    "Lexend"
                                font.pixelSize: 14
                                font.bold:      true
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Item { Layout.fillWidth: true }

                            // Next button
                            Rectangle {
                                width: 24; height: 24
                                radius: 6
                                color: nextMa.containsMouse ? "#504945" : "#3c3836"
                                Behavior on color { ColorAnimation { duration: 80 } }
                                Text {
                                    anchors.centerIn: parent
                                    text:  "›"
                                    color: "#ebdbb2"
                                    font.pixelSize: 16
                                }
                                MouseArea {
                                    id: nextMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked:    clockPanel.nextMonth()
                                }
                            }
                        }

                        // ── Day-of-week headers ───────────────────────────
                        Row {
                            Layout.fillWidth: true
                            Repeater {
                                model: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                                Text {
                                    width: calLayout.width / 7
                                    text:  modelData
                                    color: "#665c54"
                                    font.family:    "Lexend"
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // ── Calendar grid ─────────────────────────────────
                        Item {
                            Layout.fillWidth: true
                            height: 28 * 6

                            Repeater {
                                model: clockPanel.calCells

                                delegate: Item {
                                    x:      (index % 7) * (parent.width / 7)
                                    y:      Math.floor(index / 7) * 28
                                    width:  parent.width / 7
                                    height: 28

                                    // Today highlight — filled circle
                                    Rectangle {
                                        visible:          modelData.isToday
                                        anchors.centerIn: parent
                                        width: 24; height: 24
                                        radius: 12
                                        color: "#fabd2f"
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text:  modelData.day
                                        color: modelData.isToday ? "#1d2021"
                                             : modelData.inMonth ? "#ebdbb2"
                                             : "#504945"
                                        font.family:    "Lexend"
                                        font.pixelSize: 13
                                        font.bold:      modelData.isToday
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
                    Layout.topMargin:    16
                    Layout.bottomMargin: 16
                    color: "#3c3836"
                }

                // ── Neofetch column ───────────────────────────────────────
                Item {
                    id: neofetchPane
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    clip: true

                    property real scrollY: 0

                    Text {
                        id: neofetchText
                        x: 14
                        y: neofetchPane.scrollY + 12
                        width: parent.width - 28
                        text: clockPanel.neofetchOutput
                        color: "#8ec07c"
                        font.family:    "monospace"
                        font.pixelSize: 12
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
        }
    }
}
