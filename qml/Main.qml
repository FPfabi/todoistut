/*
 * Copyright (C) 2024  Fabian Huck
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * todoistut is distributed in the hope that it will be useful,PopupUtils
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Dialogs 1.3
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

import "Global.js" as Glob
import "Database.js" as Db

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'todoistut.fabianhuck'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property string scope: "ProjectList"
    property string cur_pid: ""
    property string cur_tid: ""  //currently selected task id
    property string setting_dialog_title: ""
    property string api_key: ""
    property bool setting_dialog_open: false


    function loadStructure() {
        console.log('module imported');
        py.call('todoist.load_structure_wrapper', [root.api_key], function(ret) {
            if(ret.projects.length == 0){
                // raise warning that no projects found
                // info about api_key in settings
                return;
            }

            Glob.projects = ret.projects;  //Save projects to JS Glob
            Glob.tasks = ret.tasks;  //Save projects to JS Glob
            Glob.persons = ret.persons;
            loadPersons();
            showList();
            progress.running = false;                                        
        })
    }

    function init_python() {
        console.log('module imported');
        py.call('todoist.init', [root.api_key], function(ret) {
            console.log(ret);                                       
        })
    }

    
    function showList() {
        console.log("Showlist code");
        
        console.log(scope);
        todolistModel.clear();
        switch(scope) {
        case "ProjectList":
            console.log("Showing all projects");
            // code block
            for (const p of Glob.projects) { // You can use `let` instead of `const` if you like
                console.log("showlist: " + p.name + ", " + p.id + ", " + p.is_favorite);
                todolistModel.append({"item_type": "project", "header": p.name, "subheader": "SubHeader", "id": p.id, "assignee_name": "", "due_date":"", "comment_count": p.comment_count, "is_favorite": p.is_favorite, "num_tasks": p.num_tasks, "created_at": ""});
                //console.log(t.content);
            }  
            break;
        case "Section":
            // code block
            break;
        case "Project":
            // code block
            console.log("Showing all tasks in project");
            for (const t of Glob.tasks) { // You can use `let` instead of `const` if you like
                console.log("showlist: " + t.content + ", " + t.id + ", " + t.assignee_name  + ", " + t.due_date + ", " + t.created_at);
                if(cur_pid != ""){
                    if(t.project_id == cur_pid){
                        todolistModel.append({"item_type": "task", "header": t.content, "subheader": t.assignee_name, "id": t.id, "assignee_name": t.assignee_name, "due_date": t.due_date, "comment_count": t.comment_count, "is_favorite": false, "num_tasks": 0, "created_at": t.created_at});
                    }
                }else{
                    todolistModel.append({"item_type": "task", "content": "Error"});
                }
                
                //console.log(t.content);
            }  
            break;
        default:
            // code block
        } 
    }

    function loadPersons(){
        personlistModel.clear();
        for (const p of Glob.persons) { // You can use `let` instead of `const` if you like
            console.log("loadPersons: " + p.name + ", " + p.id+  ", " + p.email);
            personlistModel.append({"name":p.name, "id": p.id, "email": p.email});
            //console.log(t.content);
        }  
    }

    function loadComments(){
        commentslistModel.clear();

        py.call('todoist.get_comments_dict', [root.cur_tid], function(comments_list) {
            // async call
            for (const c of comments_list) { // You can use `let` instead of `const` if you like
                console.log("get_comments: " + c.content);
                commentslistModel.append(c);
            } 
        });
    }

    function show_comments_popup_dialog(){
        //commentsPopup.cur_task_id = Glob.cur_id;
        console.log("showing comments popup");
        PopupUtils.open(commentsPopup);
    }

    //function is not used at the moment. Instead, onEntryLongPressed of Listview is used
    function show_task_popup_dialog(){
        var cur_task = Glob.get_task(Glob.cur_id);  //TODO: Check if you can link only the dictionary, and the qml items take their property from there
                
        for (const key in cur_task) {
            if (cur_task.hasOwnProperty(key)) {
                console.log(`Key: ${key}, Value: ${cur_task[key]}`);
            }
        }
        
        taskPopup.cur_task_id = Glob.cur_id;
        taskPopup.task_name = cur_task.content;
        taskPopup.task_description = Glob.string_or_empty(cur_task.description);
        taskPopup.task_due_date = cur_task.due_date;
        taskPopup.task_assignee_id = Glob.string_or_empty(cur_task.assignee_id);
        taskPopup.newTask = cur_task;

        var personIndex = Glob.get_index(Glob.persons, cur_task.assignee_id); //personIndex is NOT the id, just the order in the listview
        taskPopup.selected_person_index = personIndex;
        //taskPopup.personListView.currentIndex = personIndex;

        taskPopup.open();
    }

    function update_task(t){
        console.log("inside function update_task. t values:");
        Glob.print_dictionary(t);

        py.call('todoist.update_task', [t], function(updated_task) {
            // async call
            if ("error" in updated_task == false){
                Glob.js_replace_task(t);  //Save projects to JS Glob
                showList();
            }else{
                messageDialog.text = "Error updating task " + updated_task.error;
                messageDialog.open()
            }
        });

    }

    ActivityIndicator {
        id: progress
        anchors.centerIn: parent
        running: true
        visible: running
    }

    MessageDialog {
        id: messageDialog
        title: "Alert"
        text: "This is a short alert message."
    }

    ListModel {
        id: todolistModel
        dynamicRoles: true
    }
    ListModel {
        id: personlistModel
        dynamicRoles: true
    }
    ListModel {
        id: commentslistModel
        dynamicRoles: true
    }

    MessageDialog {
        id: msgBox
        title: "Information"
        text: "This is a simple message box."
        standardButtons: MessageDialog.Ok
    }

    Component {
        id: removeAllDialog

        OKCancelDialog {
            title: i18n.tr("Remove all items")
            text: i18n.tr("Are you sure?")
            onDoAction: console.log("Remove all items")
        }
    }

    Component {
        id: removeSelectedDialog

        OKCancelDialog {
            title: i18n.tr("Remove selected items")
            text: i18n.tr("Are you sure?")
            onDoAction: console.log("Remove selected items")
        }   
    }

    Component {
        id: aboutDialog
        AboutDialog {}
    }

    TaskPopup {
        id: taskPopup
    }
    
    Component {
        id: commentsPopup
        CommentsPopup {}
    }

    Component {
        id: settingDialog
        SettingDialog {}
    }

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('Todoist UT')
            subtitle: i18n.tr('Unofficial todoist client')

            ActionBar {
                id: actionBar
                anchors {
                    top: header.top
                    right: parent.right
                    topMargin: units.gu(1)
                    rightMargin: units.gu(1)
                }
                numberOfSlots: 2
                actions: [
                    Action {
                        iconName: "filter"
                        iconSource: "graphics/filter-inactive.svg"
                        text: i18n.tr("Filter")
                    },
                    Action {
                        iconName: "settings"
                        text: i18n.tr("Settings")
                        onTriggered: PopupUtils.open(settingDialog)
                    },
                    Action {
                        iconName: "info"
                        text: i18n.tr("About")
                        onTriggered: PopupUtils.open(aboutDialog)
                    },
                    Action {
                        iconName: "delete"
                        text: i18n.tr("Reset")
                        onTriggered: {
                            Db.purge();
                        }
                    }
                ]
            }
             
        }

        //Navigation Pane
        Row {
            id: navi_row
            spacing: units.gu(1)
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                topMargin: units.gu(1)
                bottomMargin: units.gu(2)
                leftMargin: units.gu(2)
                rightMargin: units.gu(2)
            }
            Label {
                id: lblProjectList
                text: i18n.tr("All")
                font.bold: scope == "ProjectList"? true: false
                MouseArea {
                    anchors.fill: parent
                    onClicked:{
                        scope = "ProjectList";
                        showList();                        
                    }
                }

            }
            Label {
                id: lblSep0
                text: i18n.tr(">")
            }
            Label {
                id: lblProject
                text: i18n.tr("Project")
                font.bold: scope == "Project"? true: false
                MouseArea {
                    anchors.fill: parent
                    onClicked:{
                        scope = "Project";
                        showList();                        
                    }
                }

            }
            Label {
                id: lblSep1    //todolistModel.append({"name": textFieldInput.text})
                text: i18n.tr(">")
            }
            Label {
                id: lblSection
                text: i18n.tr("Section")
                font.bold: scope == "Section"? true: false
            }
            Label {
                id: lblSep2
                text: i18n.tr(">")
            }
            Label {
                id: lblTask
                text: i18n.tr("Task")
                font.bold: scope == "Task"? true: false
            }

            
            
        }     

        Button {
            id: buttonAdd
            anchors {
                top: navi_row.bottom
                right: parent.right
                topMargin: units.gu(2)
                rightMargin: units.gu(2)
            }
            text: i18n.tr('Add')
            onClicked: {
                if(scope == "ProjectList"){
                    //when scope is on project list then add a project
                    //todolistModel.append({"name": textFieldInput.text})
                    py.call('todoist.add_project', [textFieldInput.text], function(all_proj) {
                        // async call
                        console.log('after call');
                        textFieldInput.text = "";
                        Glob.projects = all_proj;  //Save projects to JS Glob
                        showList();
                    });
                }else if(scope == "Project"){
                    //When scope is on project then add a task
                    py.call('todoist.add_task', [cur_pid, textFieldInput.text], function(new_task) {
                        // async call
                        console.log('after create new task call');
                        textFieldInput.text = "";
                        Glob.tasks.push(new_task);  //Save projects to JS Glob
                        showList();
                    });
                }
            }
        }

        TextField {
            id: textFieldInput
            anchors {
                top: navi_row.bottom
                left: parent.left
                topMargin: units.gu(2)
                leftMargin: units.gu(2)
            }
            placeholderText: i18n.tr("New Item Name")
        }

        ListView {
            id: todolistView
            signal entryDeletedClicked(string id);
            signal entryLongPressed(string id);
            signal showCommentsPressed(string id);
            onEntryLongPressed:{
                console.log("Entry Long pressed, id:", id);
                Glob.cur_id = id;
                show_task_popup_dialog(); //fill popup and show
            }
            onEntryDeletedClicked: {
                switch(scope) {
                case "ProjectList":
                    console.log("Deleting project");
                    // code block
                    py.call('todoist.delete_project', [id], function(worked) {
                        if(worked == true){
                            Glob.js_delete_project(id);
                        }else{
                            console.log("Error: Deleting project failed!!!")
                        }
                        showList();
                    });
                    break;
                case "Section":
                    // code block
                    break;
                case "Project":
                    console.log("Deleting task");
                    
                    // code block
                    py.call('todoist.delete_task', [id], function(worked) {
                        if(worked == true){
                            Glob.js_delete_task(id);
                        }else{
                            console.log("Error: Deleting task failed!!!");
                            
                        }
                        showList();
                    });
                    break;
                default:
                    // code block
                } 
            }
            onShowCommentsPressed:{
                console.log("showComments pressed, id:", id);
                Glob.cur_id = id;
                root.cur_tid = id;
                loadComments();
                show_comments_popup_dialog();
            }
            anchors {
                top: textFieldInput.bottom
                bottom: bottomControls.top
                left: parent.left
                right: parent.right
                topMargin: units.gu(2)
            }
            model: todolistModel

            delegate: ProjectItemDelegate3{
                Component.onCompleted: {
                    entryDeleteClicked.connect(todolistView.entryDeletedClicked)
                    entryLongPressed.connect(todolistView.entryLongPressed)
                    showCommentsPressed.connect(todolistView.showCommentsPressed)
                }
            }
        }

        Row {
            id: bottomControls
            visible: false
            spacing: units.gu(1)
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                topMargin: units.gu(1)
                bottomMargin: units.gu(2)
                leftMargin: units.gu(2)
                rightMargin: units.gu(2)
            }
            Button {
                id: buttonRemoveAll
                text: i18n.tr("Remove all...")
                width: parent.width / 2 - units.gu(0.5)
                onClicked: PopupUtils.open(removeAllDialog)
            }
            Button {
                id: buttonRemoveSelected
                text: i18n.tr("Remove selected...")
                width: parent.width / 2 - units.gu(0.5)
                onClicked: PopupUtils.open(removeSelectedDialog)
            }
        }  
    }

    Python {
        id: py

        Component.onCompleted: {
            //Db.purge();  --> e58XXXXXXXXXXXXXXXXXXXXXXXXXX deletes the database
            Db.init();
            //Db.addSetting2("api_key", "4545");

            root.api_key = Db.getSetting("api_key");
            
            console.log("api key retrieved from db: " + root.api_key);

            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('todoist', function() {
                console.log('module imported');
                
                py.call('todoist.load_structure_wrapper', [root.api_key], function(ret) {
                    if(ret.errors.length > 0){
                        // raise warning that no projects found
                        // info about api_key in settings
                        if(ret.errors[0].length > 0){
                            if(setting_dialog_open == false){
                                setting_dialog_open = true;
                                //setting_dialog_title = "Error happend: " + ret.errors[0] + "(No api key?)";
                                setting_dialog_title = "Todoist API token must be entered. Please retrieve from website https://app.todoist.com (Settings -> Integrations -> Developer -> API Token)"
                                PopupUtils.open(settingDialog);
                            }
                        }
                    }

                    Glob.projects = ret.projects;  //Save projects to JS Glob
                    Glob.tasks = ret.tasks;  //Save projects to JS Glob
                    Glob.persons = ret.persons;
                    loadPersons();
                    Glob.linkStructure();
                    showList();
                    progress.running = false;                                        
                })
            });
        }

        onError: {
            progress.running = false;   
            
            console.log('python onError: ' + traceback);
            
            if(setting_dialog_open == false){
                setting_dialog_open = true;
                setting_dialog_title = "onError happend: " + traceback + "(No api key?)";
                PopupUtils.open(settingDialog);
            }
        }
    }    
}