import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Dialog {
    id: dialog
    title: i18n.tr("About")

    Label {
		width: parent.width
		wrapMode: Text.WordWrap
        text: i18n.tr("This is an ubuntu touch client for the Todoist REST service. It is implemented via its public python SDK.")
    }

    Button {
        text: i18n.tr("Close")
        onClicked: PopupUtils.close(dialog)
    }
}
