import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "Database.js" as Db



Dialog {
    id: commentsPopup
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

        UbuntuListView {
            id: commentsListView
            width: parent.width
            height: parent.height
            model: commentslistModel
            delegate: Rectangle {
                height: 25
                width: 100
                Text { text: "Content: " + content}
            }
        }

        Row {
            id: popupRowButtons
            spacing: units.gu(1)
            Button {
                text: "Close"
                onClicked: commentsPopup.close()
            }
            Button {
                text: "Apply"
                onClicked: {
                    //TODO: Perform update
                    commentsPopup.newTask["content"] = popupTaskName.text;
                    commentsPopup.newTask["description"] = popupTaskDesc.text;
                    commentsPopup.newTask["due_string"] = popupTaskDue.text;
                    commentsPopup.newTask["assignee_id"] = taskPopup.task_assignee_id;

                    //update_task(taskPopup.newTask);
                    commentsPopup.close()
                }
            }
        }
        
    }
}