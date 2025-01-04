import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Dialogs 1.3
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4
import Ubuntu.Components 1.3


Popup {
    id: taskPopup
    property string cur_task_id: ""
    property string task_name: ""
    property string task_description: ""
    property string task_due_date: ""
    property string task_assignee_id: ""
    property int selected_person_index: -1
    
    property var newTask: {}  // stores a copy of the task dictionary

    anchors.centerIn: parent
    width: parent.width - units.gu(1)
            
    Column {
        spacing: units.gu(2)
        anchors.fill: parent
        anchors.margins: units.gu(2)

        TextField {
            id: popupTaskName
            width: parent.width
            placeholderText: "Task name"
            text: taskPopup.task_name

            // Add a new signal here
            signal keyPressed(var event)

            // Connect the existing signal to our new signal
            Keys.onPressed: keyPressed(event)
        }
        TextField {
            id: popupTaskDesc
            width: parent.width
            placeholderText: "Task Description"
            text: taskPopup.task_description

            // Add a new signal here
            signal keyPressed(var event)

            // Connect the existing signal to our new signal
            Keys.onPressed: keyPressed(event)
        }

        
        ComboButton {
            id: combo
            width: parent.width

            signal personselected(string id)

            onPersonselected: {
                console.log('Person with ID ' + id + ' was selected')
                taskPopup.task_assignee_id = id;
            }

            text: i18n.tr("Select Person")
            expanded: false
            collapsedHeight: units.gu(4)

            expandedHeight: units.gu(25)
            onClicked: expanded = true
            UbuntuListView {
                id: personListView
                width: parent.width
                height: combo.comboListHeight
                model: personlistModel
                delegate: EventItemDelegate{
                    Component.onCompleted: {
                        itemclicked.connect(combo.personselected);
                    }
                }
            }
        }

        TextField {
            id: popupTaskDue
            width: parent.width
            placeholderText: "Due date"
            text: taskPopup.task_due_date

            // Add a new signal here
            signal keyPressed(var event)

            // Connect the existing signal to our new signal
            Keys.onPressed: keyPressed(event)
        }

        Row {
            id: popupRowButtons
            spacing: units.gu(1)
            Button {
                text: "Close"
                onClicked: taskPopup.close()
            }
            Button {
                text: "Apply"
                onClicked: {
                    //TODO: Perform update
                    taskPopup.newTask["content"] = popupTaskName.text;
                    taskPopup.newTask["description"] = popupTaskDesc.text;
                    taskPopup.newTask["due_string"] = popupTaskDue.text;
                    taskPopup.newTask["assignee_id"] = taskPopup.task_assignee_id;

                    update_task(taskPopup.newTask);
                    taskPopup.close()
                }
            }
        }
        Connections {
            target: popupTaskName
            onKeyPressed: {
                taskPopup.task_name = popupTaskName.text
            }
        }
        Connections {
            target: popupTaskDesc
            onKeyPressed: {
                taskPopup.task_description = popupTaskDesc.text
            }
        }
        Connections {
            target: popupTaskDue
            onKeyPressed: {
                taskPopup.task_due_date = popupTaskDue.text
            }
        }
    }
    onOpened: {
        console.log("Taskpopup onOpened; Index: " + taskPopup.selected_person_index)
        if(taskPopup.selected_person_index < 0){
            //personListView.currentIndex = taskPopup.selected_person_index;
            combo.personselected(taskPopup.selected_person_index);
            var selPersonName = personlistModel.get(taskPopup.selected_person_index).name;
            combo.text = selPersonName;
        }
    }
}