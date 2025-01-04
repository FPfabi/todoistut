import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Dialog {
    id: dialog
    signal doAction()

    Button {
        text: i18n.tr("OK")
        color: theme.palette.normal.negative
        onClicked: {
            PopupUtils.close(dialog)
            doAction()
        }
    }

    Button {
        text: i18n.tr("Cancel")
        onClicked: PopupUtils.close(dialog)
    }
}
