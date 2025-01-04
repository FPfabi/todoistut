import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Dialog {
    id: dialog
    title: i18n.tr("About")

    Label {
		width: parent.width
		wrapMode: Text.WordWrap
        text: i18n.tr("This is an example shopping list app designed to teach you Ubuntu Touch app development.")
    }

    Button {
        text: i18n.tr("Close")
        onClicked: PopupUtils.close(dialog)
    }
}
