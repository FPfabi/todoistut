/*
 * Copyright (C) 2024  Fabian Huck
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * todoistut is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'todoistut.fabianhuck'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('Todoist UT')
        }

        ListView {
            model: ListModel {
                Component.onCompleted: {
                    for (var i = 0; i < 100; i++) {
                        append({tag: "List item #"+i});
                    }
                }
            }
            delegate: ListItem {
                // shall specify the height when Using ListItemLayout inside ListItem
                height: modelLayout.height + (divider.visible ? divider.height : 0)
                ListItemLayout {
                    id: modelLayout
                    title.text: modelData
                }
                color: dragMode ? "lightblue" : "lightgray"
                onPressAndHold: ListView.view.ViewItems.dragMode =
                    !ListView.view.ViewItems.dragMode
            }
            ViewItems.onDragUpdated: {
                if (event.status == ListItemDrag.Moving) {
                    model.move(event.from, event.to, 1);
                }
            }
            moveDisplaced: Transition {
                LomiriNumberAnimation {
                    property: "y"
                }
            }
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('todoist', function() {
                console.log('module imported');
                python.call('todoist.speak', ['Hello World!'], function(returnValue) {
                    console.log('todoist.speak returned ' + returnValue);
                })
            });
        }

        onError: {
            console.log('python error: ' + traceback);
            lbl.text = traceback;
        }
    }
}
