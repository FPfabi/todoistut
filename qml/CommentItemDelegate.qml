import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3

import QtQuick.Layouts 1.3
import "Global.js" as Glob

/*
       Delegate component used to display an Item conteined in a ListView (or UbuntuListView)
       It receives as in input the ListModel and can extract items properties values from the items
       (ie the keys of Json obejct)
    */
ListItem {
    id: commentItem
    signal entryDeleteClicked(string id);
    signal entryLongPressed(string id);
    signal showCommentsPressed(string id);
    
    width: parent.width
    height: units.gu(6)

    property color bgcolor: "lightgrey"
   
    Rectangle{
        anchors.fill: parent
        
        Row {
            id:commentRow1
            height: units.gu(4)
            width: parent.width
            spacing: 10 // Space between text items
            Rectangle {
                id: iconRect
                height: parent.height
                width: units.gu(3)
                
                Image {
                    id: commentIconLeft
                    height: units.gu(3)
                    width: units.gu(8)
                    fillMode: Image.PreserveAspectFit
                    source: "graphics/comment-black-empty.svg"
                    anchors.centerIn: parent
                }
            }
            Rectangle{
                height: parent.height
                width: commentRow1.width - iconRect.width - commentRow1.spacing
                color: bgcolor
                radius: units.gu(1)
                Text {
                    text: content
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: units.gu(2)
                }
            }
        }
    }
}