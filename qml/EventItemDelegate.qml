import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

import QtQuick.Layouts 1.3

/*
       Delegate component used to display an Item conteined in a ListView (or UbuntuListView)
       It receives as in input the ListModel and can extract items properties values from the items
       (ie the keys of Json obejct)
    */
Item {
    id:  eventItem

    signal itemclicked(string id)

    width: combo.width
    height: units.gu(5) /* heigth of the rectangle container */
    visible: true;

    /* create a container for each job */
    Rectangle {
        id: background
        x: 2; y: 2; width: parent.width - x*2; height: parent.height - y*1
        border.color: "black"
        radius: 5
    }

    /* The mouse region covers the entire delegate */
    MouseArea {
        id: selectableMouseArea
        anchors.fill: parent
        onClicked: {
            combo.expanded=false;
            combo.text = name
            eventItem.itemclicked(id)
        }
    }

    /* create a row for each item in the ListModel */

    RowLayout {
        id: layout
        //anchors.fill: eventItem
        anchors.centerIn: parent
        width: parent.width - units.gu(2)
        height: parent.height

        spacing: 0
        Rectangle {
            id:filtername
            color: 'transparent' //transparent
            Layout.fillWidth: true
            Layout.minimumWidth: units.gu(10)
            Layout.preferredWidth: units.gu(30)
            Layout.maximumWidth: units.gu(40)
            height: eventItem.height
            //anchors.verticalCenter: eventItem
            Text {
                //anchors.centerIn: parent
                anchors.left:parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: name
            }
        }

    }





}
