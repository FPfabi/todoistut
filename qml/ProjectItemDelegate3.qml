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
    id: todoListItem
    signal entryDeleteClicked(string id);
    signal entryLongPressed(string id);
    signal showCommentsPressed(string id);
    
    width: parent.width
    height: units.gu(10)

    MouseArea {
        anchors.fill: parent
        onClicked:{
            if(scope == "ProjectList"){
                cur_pid = id;
                scope = "Project";
                showList();
            }
        }
        onPressAndHold:{
            entryLongPressed(id);
        }
    }
    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                onTriggered: {
                    entryDeleteClicked(id);
                }
            }
        ]
    }
   

    Column {
        anchors.fill: parent
        spacing: 2

        Row {
            height: units.gu(4)
            width: parent.width
            spacing: 10 // Space between text items
            Rectangle{
                height: parent.height
                width: parent.width/3*2
                Text {
                    text: header
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: units.gu(2)
                }
            }
            Rectangle{
                height: parent.height
                width: parent.width/3

                Text {
                    id: created_item
                    text: created_at
                    visible: false
                    horizontalAlignment: Text.AlignRight
                    anchors.right: due_item.left // Align to the right side of the Row
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }

                Text {
                    id: due_item
                    text: due_date
                    horizontalAlignment: Text.AlignRight
                    anchors.right: parent.right // Align to the right side of the Row
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
            }
        }

        Row {
            height: units.gu(4)
            width: parent.width
            spacing: 10 // Space between text items
            Rectangle{
                height: parent.height
                width: parent.width/3*2
                Text {
                    visible: scope == "Project"
                    text: subheader
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.margins: units.gu(2)
                }
                Rectangle {
                    visible: scope == "ProjectList"
                    height: parent.height
                    width: units.gu(3)
                    anchors.left: parent.left // Align to the right side of the Row
                    anchors.margins: units.gu(2)
                    Text{
                        id: txtFavorite
                        visible: false
                        text: is_favorite
                    }
                    Image {
                        id: starredIcon
                        height:units.gu(2)
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                        source: {
                            //"graphics/min15.svg"
                            if(is_favorite == true){
                                return "graphics/starred.svg"
                            }else{
                                return "graphics/unstarred.svg"
                            }
                        }
                    }
                }
            }
            Rectangle{
                height: parent.height
                width: parent.width/3

                Rectangle {
                    id: numtasksRect
                    height: parent.height
                    width: units.gu(3)
                    anchors.right: txt_tasks.left // Align to the right side of the Row
                    //anchors.margins: units.gu(2)
                    Image {
                        id: tasksIcon
                        height:units.gu(2)
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                        source: "graphics/task-black.svg"
                        anchors.centerIn: parent
                    }
                }
                Text {
                    id: txt_tasks
                    text: num_tasks
                    horizontalAlignment: Text.AlignRight
                    anchors.right: commentRect.left // Align to the right side of the Row
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }



                //Comment icon and comment number
                Rectangle {
                    id: commentRect
                    height: parent.height
                    width: units.gu(3)
                    anchors.right: txt_comments.left // Align to the right side of the Row
                    //anchors.margins: units.gu(2)
                    Image {
                        id: commentIcon
                        height:units.gu(2)
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                        source: "graphics/comment-black.svg"
                        anchors.centerIn: parent
                    }
                }
                Text {
                    id: txt_comments
                    text: comment_count
                    horizontalAlignment: Text.AlignRight
                    anchors.right: parent.right // Align to the right side of the Row
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
            }
        }
    }



    trailingActions: ListItemActions {
        actions: [
            Action {
                //iconName: "edit"
                text:i18n.tr("comment")
                iconSource: "graphics/comment-black.svg"
                onTriggered: showCommentsPressed(id) //Is Connected to Mail Listview on FirstPage.qml
            },
            Action {
                visible: (scope == "ProjectList")
                text:i18n.tr("favorite")
                iconName: "starred"
                onTriggered: entryTimeModClicked(recordId, -30) //Is Connected to Mail Listview on FirstPage.qml
            }
        ]
    }


    Component.onCompleted: {
        var isClose = Glob.isCloseToDate(created_at, due_date)
        console.log(created_item.text);
        console.log("due_date: " + due_date);
        console.log("Checking if close:" + isClose)
        if(isClose == true){
            due_item.color = "red";
        }
    }
}