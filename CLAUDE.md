# Cogitator Shell — Developer Notes

Quickshell-based Wayland status bar and overlay system. Warhammer 40k Cogitator aesthetic: black background, phosphor green text and borders, no rounding, VT323/First Legion fonts, CRT scanline overlays.

---

## Architecture

### Window model

Quickshell has two relevant window types:

**`WlrLayershell`** — a proper Wayland layer-shell surface. Anchored to screen edges, placed on a specific layer (`Top`, `Overlay`, etc.) by the compositor. The statusbar lives here. It has `keyboardFocus: WlrKeyboardFocus.None` so it never steals focus from real windows.

**`PanelWindow`** — a Quickshell abstraction over another layer-shell surface type. No `keyboardFocus` property. Used for the settings panel and the volume OSD. Receives pointer events by default. `mask: Region {}` opts it out (used in `VolumeOsd` to make the popup click-through).

**Critical:** `PanelWindow` must be a direct child of `Scope` — a sibling to `WlrLayershell`, not nested inside it. Nesting causes the child to inherit the parent's input settings, making it visually present but dead to mouse input.

### Input system

Qt 6 has two parallel input systems:

- **`MouseArea`** — old system, reliable everywhere including Wayland layer-shell
- **`PointerHandlers`** (`DragHandler`, `TapHandler`) — new system, used internally by `QtQuick.Controls.Slider`

`Slider` from `QtQuick.Controls` does **not** work in wlr-layer-shell surfaces on Hyprland. All interactive controls use `MouseArea` directly. Custom sliders are `Item` + `Rectangle` (track) + `Rectangle` (handle) + `MouseArea`.

### QML binding trap for live controls

`value: backendValue` on a slider re-evaluates eagerly — every time the backend changes (including during a drag) QML resets the position, making the slider appear broken. The fix:

```qml
Connections {
    target: backend
    function onValueChanged() {
        if (!mouseArea.pressed) sliderItem.value = backend.value
    }
}
```

The backend only drives the UI when the user isn't actively holding the control.

---

## File map

```
shell.qml            Root. Loads fonts. Creates WlrLayershell (statusbar) and
                     PanelWindow (settings panel) as Scope-level siblings.
                     Also instantiates VolumeOsd and WindowTabs.

StatusBar.qml        Statusbar content: WorkspaceWidget, ClockWidget (centered),
                     TrayWidget, SettingsButton. Owns `settingsPanelOpen` bool
                     and the toggle function. Shell reads it to control PanelWindow
                     visibility.

SettingsButton.qml   Right-side status bar toggle button. Canvas draws a 3-line
                     equalizer icon. Fires `toggleRequested` on click.

WorkspaceWidget.qml  Hyprland workspace boxes I–X. VI–X only render when occupied.
                     Roman numerals via toRoman(). Hyprland.dispatch() to switch.

ClockWidget.qml      Text + 1s Timer. Uses Qt.formatDateTime.

TrayWidget.qml       Repeater over SystemTray.items. layer.enabled + MultiEffect
                     colorizes each icon green. MouseArea handles left/middle/right
                     and scroll.

VolumeOsd.qml        Scope (not a window). Watches sink volume, activates a
                     LazyLoader on change. LazyLoader creates a bottom-center
                     PanelWindow (click-through via mask: Region {}) with a
                     progress bar. Hides after 1s.

WindowTabs.qml       Variants driven by focusedWorkspace.toplevels. One PanelWindow
                     per open window, positioned above its title bar gap. Sanctioned
                     apps (kitty, dolphin, fuzzel) get green tab; everything else
                     gets #cc4400 "HERESY".

VolumeStatus.qml     UNUSED — superseded by SettingsButton.qml. Safe to delete.

darktide_quotes.txt  Raw source list, one quote per line. Not used directly at runtime.
darktide_quotes.js   Generated JS library (`python3` from the .txt). Imported in shell.qml
                     as `DarktideQuotes`. Contains 192 Warhammer 40k loading screen
                     quotes from Darktide. To regenerate after editing the txt:
                       python3 -c "
                       import json
                       q = [l.strip() for l in open('darktide_quotes.txt') if l.strip()]
                       open('darktide_quotes.js','w').write('.pragma library\nvar quotes = ' + json.dumps(q, indent=4) + '\n')
                       "
                     Source: https://gist.github.com/pmarreck/1548c09877ac012ed181fa067fd9b1d7
```

---

## Pipewire integration

`Pipewire.defaultAudioSink` / `defaultAudioSource` return node references, but nodes are "untracked" without a `PwObjectTracker`. Without one, the `audio` property may be null and volume won't be writable. The settings panel owns a `PwObjectTracker` for both sink and source. `VolumeOsd` has a separate one for just the sink. Multiple trackers for the same node are harmless.

---

## Theme

All values are hardcoded inline — no global theme object. When changing a color, find and update every occurrence manually.

| Purpose | Value |
|---|---|
| Active / bright green | `#39ff14` |
| Medium green (occupied, borders) | `#1a7a1a` |
| Dim green (empty slots) | `#0a3300` |
| Active bg tint | `#040f04` |
| Background | `#000000` |
| Heresy / non-sanctioned | `#cc4400` |
| Heresy inactive border | `#3a1000aa` |

**Fonts:** First Legion (workspace labels), VT323 (everything else). Both loaded via `FontLoader` in `shell.qml`'s root `Scope`.

**Scanlines:** Canvas overlay at z:100, `enabled: false`. Fills a 6% green phosphor tint across the whole surface, then draws 28% opaque black 1px bands every 3px to create the CRT scan effect.

**Icon theme:** `//@ pragma IconTheme Papirus` at top of `shell.qml`.

---

## Gotchas

**`FontLoader` must live in `Scope`, not inside `WlrLayershell`.** `WlrLayershell` is a window type and counts as the root item of its surface. A `FontLoader` before it would create a second root item — QML forbids this.

**`PanelWindow` has no `border` property.** Fake it with a child `Rectangle { color: "transparent"; border.color: ...; z: 101; enabled: false }`. The `enabled: false` is critical — without it the transparent rectangle sits on top and swallows mouse events.

**The scanline `Canvas` also needs `enabled: false`.** Even without a `MouseArea`, overlay items at high z-order intercept hit testing in Qt Quick.

**`windowrulev2` is deprecated in Hyprland.** Use `windowrule {}` block syntax. The property inside is `border_color`, not `bordercolor`.

**`WindowTabs` model is `HyprlandToplevel`, not `HyprlandWindow`.** Use `Hyprland.focusedWorkspace.toplevels` as the model, not `Hyprland.toplevels.values`. Position and class come from `modelData.lastIpcObject` (raw IPC JSON map).

**`PanelWindow` inside `WlrLayershell` breaks mouse input.** They are both window types. Nesting them in the QML tree causes the inner one to inherit the outer one's surface settings. Always declare both at the `Scope` level.

**`QtQuick.Controls.Slider` does not work in layer-shell on Hyprland.** It uses `DragHandler` internally which doesn't function in this context. Use `MouseArea`-based custom sliders instead.
