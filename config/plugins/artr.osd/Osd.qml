import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "OsdModel.js" as OsdModel

Item {
  id: root

  property bool opened: false
  property string icon: ""
  property string message: ""
  property string iconKey: ""
  property int value: 0
  property int maxValue: 100
  property bool hasProgress: true
  property int duration: 1200

  readonly property bool mediaOsd: iconKey.indexOf("media") === 0 || iconKey.indexOf("player") === 0

  // Compact, measured layout: the card wraps its content with consistent
  // padding so the surface stays calm and unobtrusive.
  readonly property int padX: Style.space(10)
  readonly property int padY: Style.space(6)
  readonly property int gap: Style.space(8)
  readonly property int messageGap: Math.round(root.gap * 0.7)
  readonly property int barWidth: Style.space(96)
  readonly property int barHeight: Math.max(Style.space(4), 3)
  readonly property int maxMessageWidth: root.mediaOsd ? Style.space(220) : Style.space(140)

  // Nerd Font glyphs draw outside their advance box; measure by ink and pin the
  // progress icon column to the widest volume glyph so the bar never shifts.
  readonly property int iconInkWidth: Math.ceil(iconMetrics.tightBoundingRect.width)
  readonly property int iconWidth: root.hasProgress
    ? Math.max(root.iconInkWidth, Math.ceil(widestIconMetrics.tightBoundingRect.width))
    : root.iconInkWidth
  readonly property int valueWidth: Math.ceil(Math.max(valueMetrics.advanceWidth, messageMetrics.advanceWidth))
  readonly property int messageWidth: Math.min(Math.ceil(messageMetrics.advanceWidth), root.maxMessageWidth)
  readonly property int contentWidth: root.hasProgress
    ? root.iconWidth + root.gap + root.barWidth + root.gap + root.valueWidth
    : (root.message === "" ? root.iconWidth : root.iconWidth + root.messageGap + root.messageWidth)

  // Glass palette: a floating functional layer over content. Translucent fills
  // and a light-catching rim give depth; labels stay monochrome for legibility.
  readonly property color glassFill: Util.alpha(Commons.Color.popups.background, 0.42)
  readonly property color glassFillDeep: Util.alpha(Commons.Color.popups.background, 0.58)
  readonly property color glassRim: Util.alpha(Commons.Color.popups.text, 0.22)
  readonly property color glassSheen: Util.alpha("#ffffff", 0.22)
  readonly property color glassSheenSoft: Util.alpha("#ffffff", 0.0)
  readonly property color glassShadow: Util.alpha("#000000", 0.28)
  readonly property color trackFill: Util.alpha(Commons.Color.popups.text, 0.22)
  readonly property color trackSheen: Util.alpha(Commons.Color.popups.text, 0.10)
  readonly property color labelColor: Commons.Color.popups.text
  readonly property color accentColor: Commons.Color.accent

  function iconFor(name, percent) {
    return OsdModel.iconFor(name, percent)
  }

  function show(iconName, rawMessage, rawValue, rawMax, rawProgressText, rawDuration) {
    var next = OsdModel.stateForShow(iconName, rawMessage, rawValue, rawMax, rawProgressText, rawDuration, Commons.I18n.formatNumber)
    iconKey = next.iconKey
    maxValue = next.maxValue
    hasProgress = next.hasProgress
    value = next.value
    message = next.message
    icon = next.icon
    duration = next.duration
    opened = true
    if (duration > 0) hideTimer.restart()
    else hideTimer.stop()
  }

  function open(payloadJson) {
    try {
      var p = JSON.parse(payloadJson || "{}")
      show(p.icon || "", p.message || "", p.value === undefined ? "" : String(p.value), p.max === undefined ? "100" : String(p.max), p.progressText || "", p.duration === undefined ? "1200" : String(p.duration))
    } catch (e) {}
  }

  function close() { opened = false }

  Timer {
    id: hideTimer
    interval: root.duration
    onTriggered: root.opened = false
  }

  TextMetrics {
    id: messageMetrics
    font.family: Style.font.family
    font.weight: Font.DemiBold
    font.pixelSize: Style.font.bodySmall
    text: root.message
  }

  TextMetrics {
    id: valueMetrics
    font: messageMetrics.font
    text: Commons.I18n.formatNumber(100) + "%"
  }

  TextMetrics {
    id: iconMetrics
    font.family: Style.font.family
    font.pixelSize: Style.font.title
    text: root.icon
  }

  TextMetrics {
    id: widestIconMetrics
    font: iconMetrics.font
    text: OsdModel.widestIcon
  }

  ShellIpc {
    target: "osd"
    function show(payloadJson: string): string {
      root.open(payloadJson)
      return "ok"
    }
    function close(): string { root.close(); return "ok" }
    function state(): string { return root.opened ? "open" : "closed" }
    function ping(): string { return "ok" }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    shownKeyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "omarchy-osd"
    // Visual-only: empty input region so the OSD never blocks the desktop.
    mask: Region {}

    Item {
      id: cardWrap
      width: card.width
      height: card.height
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Style.space(48)

      opacity: root.opened ? 1 : 0
      scale: root.opened ? 1 : 0.98
      y: root.opened ? 0 : Style.space(3)

      Behavior on opacity {
        NumberAnimation { duration: root.opened ? 180 : 140; easing.type: Easing.OutCubic }
      }
      Behavior on scale {
        NumberAnimation { duration: root.opened ? 220 : 140; easing.type: Easing.OutCubic }
      }
      Behavior on y {
        NumberAnimation { duration: root.opened ? 220 : 140; easing.type: Easing.OutCubic }
      }

      // Soft separation shadow (functional layer floating above content).
      Rectangle {
        anchors.fill: card
        anchors.margins: -1
        anchors.verticalCenterOffset: Style.space(5)
        radius: card.radius + 1
        color: "transparent"
        border.width: 0
        Rectangle {
          anchors.fill: parent
          anchors.topMargin: Style.space(6)
          anchors.leftMargin: Style.space(2)
          anchors.rightMargin: Style.space(2)
          radius: parent.radius
          color: root.glassShadow
          opacity: root.opened ? 0.55 : 0
          Behavior on opacity { NumberAnimation { duration: 180 } }
        }
      }

      // Glass body.
      Rectangle {
        id: card
        width: root.padX + root.contentWidth + root.padX
        height: root.padY + Style.font.title + root.padY
        radius: Math.round(height / 2)

        // Base material: translucent fill that lets content hint through.
        color: root.glassFill

        // Depth gradient (subtle vertical falloff).
        Rectangle {
          anchors.fill: parent
          radius: parent.radius
          gradient: Gradient {
            GradientStop { position: 0.0; color: Util.alpha(root.glassFillDeep, 0.12) }
            GradientStop { position: 0.55; color: "transparent" }
            GradientStop { position: 1.0; color: Util.alpha(root.glassFillDeep, 0.22) }
          }
        }

        // Top sheen: a soft highlight as if light catches the material.
        Rectangle {
          anchors.fill: parent
          anchors.margins: 1
          radius: Math.max(0, parent.radius - 1)
          gradient: Gradient {
            GradientStop { position: 0.0; color: root.glassSheen }
            GradientStop { position: 0.45; color: root.glassSheenSoft }
            GradientStop { position: 1.0; color: "transparent" }
          }
        }

        // Hairline rim.
        Rectangle {
          anchors.fill: parent
          radius: parent.radius
          color: "transparent"
          border.width: Math.max(1, Style.space(1))
          border.color: root.glassRim
        }

        // Inner edge highlight for a carved-glass feel.
        Rectangle {
          anchors.fill: parent
          anchors.margins: 1
          radius: Math.max(0, parent.radius - 1)
          color: "transparent"
          border.width: Math.max(1, Style.space(1))
          border.color: Util.alpha("#ffffff", 0.10)
        }

        Row {
          id: contentRow
          anchors.fill: parent
          anchors.topMargin: root.padY
          anchors.rightMargin: root.padX
          anchors.bottomMargin: root.padY
          anchors.leftMargin: root.padX
          spacing: root.hasProgress ? root.gap : root.messageGap

          Item {
            width: root.iconWidth
            height: parent.height
            Text {
              textFormat: Text.PlainText
              x: Math.round((root.iconWidth - root.iconInkWidth) / 2 - iconMetrics.tightBoundingRect.x)
              anchors.verticalCenter: parent.verticalCenter
              text: root.icon
              font: iconMetrics.font
              color: root.labelColor
              opacity: 0.96
            }
          }

          Item {
            visible: root.hasProgress
            width: root.barWidth
            height: parent.height

            Rectangle {
              id: track
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width
              height: root.barHeight
              radius: height / 2
              color: root.trackFill

              // Subtle inner trough.
              Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: Math.max(0, parent.radius - 1)
                color: "transparent"
                border.width: Math.max(1, Style.space(1))
                border.color: root.trackSheen
              }

              Rectangle {
                id: fill
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                width: Math.max(parent.radius * 2, parent.width * (root.hasProgress ? root.value / root.maxValue : 0))
                radius: height / 2
                color: root.accentColor

                // Keep a pill shape at very low values without overflowing.
                clip: true
                visible: root.hasProgress && root.value > 0

                Rectangle {
                  anchors.fill: parent
                  radius: parent.radius
                  gradient: Gradient {
                    GradientStop { position: 0.0; color: Util.alpha("#ffffff", 0.28) }
                    GradientStop { position: 0.55; color: Util.alpha("#ffffff", 0.06) }
                    GradientStop { position: 1.0; color: "transparent" }
                  }
                }

                Behavior on width {
                  enabled: root.opened
                  NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.message !== ""
            width: root.hasProgress ? root.valueWidth : root.messageWidth
            horizontalAlignment: root.hasProgress ? Text.AlignRight : Text.AlignLeft
            anchors.verticalCenter: parent.verticalCenter
            text: root.message
            font: messageMetrics.font
            color: root.labelColor
            opacity: 0.96
            elide: Text.ElideRight
            maximumLineCount: 1
          }
        }
      }
    }
  }
}
