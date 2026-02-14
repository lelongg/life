import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.plasma5support 2.0 as P5Support

WallpaperItem {
    id: root
    property int elapsedWeeks: 0
    property bool avoidPanels: true
    property real manualPanelPadding: 0
    property real configuredLifetimeYears: 80.0

    function readConfigBool(value, fallbackValue) {
        if (value === undefined || value === null || value === "") {
            return fallbackValue
        }
        if (typeof value === "boolean") {
            return value
        }
        if (typeof value === "number") {
            return value !== 0
        }
        if (typeof value === "string") {
            const normalized = value.trim().toLowerCase()
            if (normalized === "true" || normalized === "1" || normalized === "yes" || normalized === "on") {
                return true
            }
            if (normalized === "false" || normalized === "0" || normalized === "no" || normalized === "off") {
                return false
            }
        }
        return fallbackValue
    }

    function readConfigNumber(value, fallbackValue) {
        if (value === undefined || value === null || value === "") {
            return fallbackValue
        }
        if (typeof value === "number" && isFinite(value)) {
            return value
        }
        const normalized = String(value).trim().replace(",", ".")
        const parsed = Number(normalized)
        return isFinite(parsed) ? parsed : fallbackValue
    }

    function syncConfigValues() {
        avoidPanels = readConfigBool(
            configuration.avoidpanels !== undefined ? configuration.avoidpanels : configuration.avoidPanels,
            true
        )
        manualPanelPadding = Math.max(
            0,
            readConfigNumber(
                configuration.panelpadding !== undefined ? configuration.panelpadding : configuration.panelPadding,
                0
            )
        )
        configuredLifetimeYears = Math.max(0.1, readConfigNumber(configuration.lifetime, 80.0))
    }

    Connections {
        target: configuration
        function onValueChanged(key, value) {
            if (key === "birthday") {
                root.updateElapsedWeeks()
            }
            if (key === "lifetime"
                || key === "avoidpanels" || key === "avoidPanels"
                || key === "panelpadding" || key === "panelPadding") {
                root.syncConfigValues()
            }
        }
    }

    // Fallback polling because config valueChanged can be unreliable depending on shell state.
    Timer {
        interval: 1500
        repeat: true
        running: true
        onTriggered: root.syncConfigValues()
    }

    readonly property real outerMargin: 1
    readonly property var availableRect: Plasmoid.availableScreenRect
    readonly property var screenRect: Plasmoid.screenGeometry
    readonly property var safeInsets: {
        if (!avoidPanels || !availableRect || availableRect.width <= 0 || availableRect.height <= 0) {
            return { "left": 0, "top": 0, "right": 0, "bottom": 0 }
        }

        // Relative mode: availableScreenRect is relative to this wallpaper item.
        const relLeft = Math.max(0, availableRect.x)
        const relTop = Math.max(0, availableRect.y)
        const relRight = Math.max(0, width - (availableRect.x + availableRect.width))
        const relBottom = Math.max(0, height - (availableRect.y + availableRect.height))
        const relValid = relLeft + relRight <= width + 1 && relTop + relBottom <= height + 1
        if (relValid) {
            return { "left": relLeft, "top": relTop, "right": relRight, "bottom": relBottom }
        }

        // Absolute mode fallback: derive insets from screenGeometry.
        if (!screenRect || screenRect.width <= 0 || screenRect.height <= 0) {
            return { "left": 0, "top": 0, "right": 0, "bottom": 0 }
        }
        const absLeft = Math.max(0, availableRect.x - screenRect.x)
        const absTop = Math.max(0, availableRect.y - screenRect.y)
        const absRight = Math.max(0, (screenRect.x + screenRect.width) - (availableRect.x + availableRect.width))
        const absBottom = Math.max(0, (screenRect.y + screenRect.height) - (availableRect.y + availableRect.height))
        const absValid = absLeft + absRight <= width + 1 && absTop + absBottom <= height + 1
        if (absValid) {
            return { "left": absLeft, "top": absTop, "right": absRight, "bottom": absBottom }
        }

        return { "left": 0, "top": 0, "right": 0, "bottom": 0 }
    }
    readonly property real contentLeftInset: outerMargin + safeInsets.left + manualPanelPadding
    readonly property real contentTopInset: outerMargin + safeInsets.top + manualPanelPadding
    readonly property real contentRightInset: outerMargin + safeInsets.right + manualPanelPadding
    readonly property real contentBottomInset: outerMargin + safeInsets.bottom + manualPanelPadding
    readonly property real contentWidth: Math.max(1, width - contentLeftInset - contentRightInset)
    readonly property real contentHeight: Math.max(1, height - contentTopInset - contentBottomInset)
    readonly property int totalWeeks: Math.max(Math.ceil(configuredLifetimeYears * 52), elapsedWeeks)
    readonly property int columns: {
        const safeTotal = Math.max(1, totalWeeks)
        const side = Math.max(1, Math.sqrt((contentWidth * contentHeight) / safeTotal) - 1)
        return Math.max(1, Math.ceil(contentWidth / side))
    }
    readonly property real tileSize: Math.max(1, Math.floor(contentWidth / columns) - 2)

    function updateElapsedWeeks() {
        const configuredBirthday = (configuration.birthday || "").trim()
        const birthday = Date.fromLocaleDateString(Qt.locale(), configuredBirthday, "yyyy-MM-dd")
        if (!birthday || isNaN(birthday.getTime())) {
            elapsedWeeks = 0
            return
        }

        const now = new Date(dataSource.data["Local"]["DateTime"])
        elapsedWeeks = Math.max(0, Math.floor((now - birthday) / 604800000))
    }

    P5Support.DataSource {
        id: dataSource
        engine: "time"
        interval: 3600000
        connectedSources: "Local"
        onDataChanged: root.updateElapsedWeeks()
        Component.onCompleted: {
            dataChanged()
        }
    }

    Component.onCompleted: {
        syncConfigValues()
        updateElapsedWeeks()
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        GridLayout {
            id: grid
            anchors.fill: parent
            anchors.leftMargin: root.contentLeftInset
            anchors.rightMargin: root.contentRightInset
            anchors.bottomMargin: root.contentBottomInset
            anchors.topMargin: root.contentTopInset
            columns: root.columns
            rowSpacing: 1
            columnSpacing: 1
            Repeater {
                model: Array(root.elapsedWeeks).fill(root.tileSize)
                Rectangle {
                    width: modelData
                    height: modelData
                    border.width: 1
                    border.color: "#4f4f4f"
                    color: "#1f1f1f"
                }
            }
            Repeater {
                model: Array(Math.max(0, root.totalWeeks - root.elapsedWeeks)).fill(root.tileSize)
                Rectangle {
                    width: modelData
                    height: modelData
                    border.width: 1
                    border.color: "#4f4f4f"
                    color: "black"
                }
            }
        }
    }
}
