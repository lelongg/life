/*
SPDX-FileCopyrightText: 2022 <>
SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.smallSpacing

    property alias cfg_birthday: birthday.text
    property alias cfg_lifetime: lifetime.text
    property var wallpaperConfiguration: wallpaper.configuration
    property bool loadingConfig: true
    readonly property int labelWidth: Math.max(birthdayLabel.implicitWidth, lifetimeLabel.implicitWidth)
    readonly property int alignedLabelWidth: Math.max(labelWidth, formAlignment - Kirigami.Units.largeSpacing)
    readonly property int birthdayFieldWidth: Kirigami.Units.gridUnit * 10
    readonly property int lifetimeFieldWidth: Kirigami.Units.gridUnit * 6

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

    Component.onCompleted: {
        const configAvoidPanels = wallpaperConfiguration.avoidpanels !== undefined
            ? wallpaperConfiguration.avoidpanels
            : wallpaperConfiguration.avoidPanels
        avoidPanels.checked = readConfigBool(configAvoidPanels, true)

        const configPanelPadding = wallpaperConfiguration.panelpadding !== undefined
            ? wallpaperConfiguration.panelpadding
            : wallpaperConfiguration.panelPadding
        const parsedPadding = Number(configPanelPadding)
        panelPadding.value = isNaN(parsedPadding) ? 0 : Math.max(0, parsedPadding)

        loadingConfig = false
    }

    RowLayout {
        spacing: Kirigami.Units.smallSpacing
        QQC2.Label {
            id: birthdayLabel
            Layout.preferredWidth: root.alignedLabelWidth
            Layout.maximumWidth: root.alignedLabelWidth
            horizontalAlignment: Text.AlignRight
            text: i18n("Birthday: ")
        }
        QQC2.TextField {
            id: birthday
            Layout.preferredWidth: root.birthdayFieldWidth
            Layout.maximumWidth: root.birthdayFieldWidth
            placeholderText: qsTr("yyyy-MM-dd")
        }
    }

    RowLayout {
        spacing: Kirigami.Units.smallSpacing
        QQC2.Label {
            id: lifetimeLabel
            Layout.preferredWidth: root.alignedLabelWidth
            Layout.maximumWidth: root.alignedLabelWidth
            horizontalAlignment: Text.AlignRight
            text: i18n("Expected lifetime: ")
        }
        QQC2.TextField {
            id: lifetime
            Layout.preferredWidth: root.lifetimeFieldWidth
            Layout.maximumWidth: root.lifetimeFieldWidth
            placeholderText: i18n("years (e.g. 80.5)")
            validator: DoubleValidator {
                bottom: 0.1
                notation: DoubleValidator.StandardNotation
            }
            onEditingFinished: {
                if (!acceptableInput) {
                    return
                }
                const normalized = text.trim().replace(",", ".")
                text = normalized
                wallpaperConfiguration.lifetime = normalized
                wallpaperConfiguration.writeConfig()
            }
        }
    }

    RowLayout {
        spacing: Kirigami.Units.smallSpacing
        Item {
            Layout.preferredWidth: root.alignedLabelWidth
            Layout.maximumWidth: root.alignedLabelWidth
        }
        QQC2.CheckBox {
            id: avoidPanels
            text: i18n("Avoid panel overlap")
            onToggled: {
                if (root.loadingConfig) {
                    return
                }
                wallpaperConfiguration.avoidpanels = checked
                wallpaperConfiguration.avoidPanels = checked
                wallpaperConfiguration.writeConfig()
            }
        }
    }

    RowLayout {
        spacing: Kirigami.Units.smallSpacing
        QQC2.Label {
            Layout.preferredWidth: root.alignedLabelWidth
            Layout.maximumWidth: root.alignedLabelWidth
            horizontalAlignment: Text.AlignRight
            text: i18n("Extra panel padding (px): ")
        }
        QQC2.SpinBox {
            id: panelPadding
            from: 0
            to: 500
            Layout.preferredWidth: root.lifetimeFieldWidth
            Layout.maximumWidth: root.lifetimeFieldWidth
            onValueChanged: {
                if (root.loadingConfig) {
                    return
                }
                wallpaperConfiguration.panelpadding = value
                wallpaperConfiguration.panelPadding = value
                wallpaperConfiguration.writeConfig()
            }
        }
    }

    Item { // tighten layout
        Layout.fillHeight: true
    }
}
