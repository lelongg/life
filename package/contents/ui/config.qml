/*
SPDX-FileCopyrightText: 2022 <>
SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4

// for "units"
import org.kde.plasma.core 2.0 as PlasmaCore

ColumnLayout {
    id: root
    spacing: PlasmaCore.Units.smallSpacing

    property alias cfg_birthday: birthday.text;
    property alias cfg_lifetime: lifetime.text;

    RowLayout {
        spacing: PlasmaCore.Units.smallSpacing
        Label {
            Layout.minimumWidth: width
            Layout.maximumWidth: width
            width: formAlignment - PlasmaCore.Units.largeSpacing
            horizontalAlignment: Text.AlignRight
            text: i18n("Birthday: ")
        }
        TextField {
            id: birthday
            Layout.fillWidth: true
            placeholderText: qsTr("yyyy-MM-dd")
        }
    }

    RowLayout {
        spacing: PlasmaCore.Units.smallSpacing
        Label {
            Layout.minimumWidth: width
            Layout.maximumWidth: width
            width: formAlignment - PlasmaCore.Units.largeSpacing
            horizontalAlignment: Text.AlignRight
            text: i18n("Expected lifetime: ")
        }
        TextField {
            id: lifetime
            Layout.fillWidth: true
            placeholderText: i18n("years")
        }
    }

    Item { // tighten layout
        Layout.fillHeight: true
    }
}
