import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "Database.js" as Db



Dialog {
    id: settingPopup
    property string api_key: ""

    Label{
        id: title
        text: setting_dialog_title
        wrapMode: "WordWrap"
    }

    TextField {
        id: popupAPIkey
        width: parent.width
        placeholderText: "Todoist API Token"
        text: settingPopup.api_key

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
            onClicked: PopupUtils.close(settingPopup)
        }
        Button {
            text: "Apply"
            onClicked: {
                progress.running = true; 
                Db.updateSetting2("api_key", popupAPIkey.text);
                root.api_key = popupAPIkey.text;
                root.init_python();
                root.loadStructure();
                root.setting_dialog_open = false;
                PopupUtils.close(settingPopup);
            }
        }
    }
    Connections {
        target: popupAPIkey
        onKeyPressed: {
            settingPopup.api_key = popupAPIkey.text
        }
    }
    Component.onCompleted:{
        console.log("Settings dialog opened");
        popupAPIkey.text = Db.getSetting("api_key");
    }
}