import QtQuick 2.1

import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: root
    property int elapsedWeeks
    property int totalWeeks: Math.max(wallpaper.configuration.lifetime * 52, elapsedWeeks)

    DataSource {
        id: dataSource
        engine: "time"
        interval: 3600000 // ms/hour
        connectedSources: "Local"
        onDataChanged: {
            var birthday = Date.fromLocaleDateString(Qt.locale(), wallpaper.configuration.birthday, "yyyy-MM-dd")
            var date = new Date(data["Local"]["DateTime"]);
            elapsedWeeks = (date - birthday)/ 604800000 // ms/week
        }
        Component.onCompleted: {
            onDataChanged();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        GridLayout {
            id: grid
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.bottomMargin: 1
            anchors.topMargin: 1
            columns: Math.ceil(width / (Math.sqrt(parent.width * parent.height / root.totalWeeks)- 1))
            rowSpacing: 1
            columnSpacing: 1
            Repeater {
                model: Array(root.elapsedWeeks).fill(Math.floor(grid.width / grid.columns)- 2)
                Rectangle {
                    width: modelData
                    height: modelData
                    border.width: 1
                    border.color: "#4f4f4f"
                    color: "#1f1f1f"
                }
            }
            Repeater {
                model: Array(root.totalWeeks - root.elapsedWeeks).fill(Math.floor(parent.width / grid.columns)- 2)
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



    function dbg(varToLog)
    {
        console.log("value: " + varToLog);
        return varToLog;
    }
}


