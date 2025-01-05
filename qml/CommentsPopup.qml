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
    

    Column{
        anchors.fill: parent
        spacing: units.gu(1)  

        Label {
            id: lblTaskName
            width: parent.width
            text: "Task: " + task_name
            font.bold: true
        }   

        UbuntuListView {
            id: commentsListView
            width: parent.width
            height: units.gu(30)
            model: commentslistModel
            delegate: CommentItemDelegate{}
        }

        Row {
            id: inputRow
            width: parent.width
            spacing: units.gu(1)        
            
            TextField {
                id: textFieldInput
                width: inputRow.width - buttonAdd.width - inputRow.spacing
                placeholderText: i18n.tr("New Comment")
            }

            Button {
                id: buttonAdd
                
                text: i18n.tr('Add')
                onClicked: {
                    console.log("Adding comment <" + textFieldInput.text + "> to task id " + commentsPopup.cur_task_id)
                    py.call('todoist.add_comment', [textFieldInput.text, commentsPopup.cur_task_id], function(retComment) {
                        // async call
                        console.log('after add_comment call');
                        commentslistModel.append(retComment)
                        textFieldInput.text = "";
                    });
                }
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