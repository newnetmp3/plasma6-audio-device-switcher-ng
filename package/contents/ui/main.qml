/*
    Copyright 2017 Andreas Krutzler <andreas.krutzler@gmx.net>
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 6.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 6.0 as QtControls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

// plasma pulseaudio plugin
import org.kde.plasma.private.volume 0.1

PlasmoidItem {
    id: main

    Layout.minimumWidth: gridLayout.implicitWidth
    Layout.minimumHeight: gridLayout.implicitHeight
    preferredRepresentation: fullRepresentation
    property int labeling: plasmoid.configuration.labeling
    property int naming: plasmoid.configuration.naming
    property bool useVerticalLayout: plasmoid.configuration.useVerticalLayout
    property bool sourceInsteadofSink: plasmoid.configuration.sourceInsteadofSink
    property bool showVirtualDevices: plasmoid.configuration.showVirtualDevices

    readonly property var sinkModelFiltered: PulseObjectFilterModel {
        id: sinkModelFiltered
        filterOutInactiveDevices: true
        filterVirtualDevices: !showVirtualDevices
        sourceModel: SinkModel {}
    }

    readonly property var sourceModelFiltered: PulseObjectFilterModel {
        id: sourceModelFiltered
        filterOutInactiveDevices: true
        filterVirtualDevices: !showVirtualDevices
        sourceModel: SourceModel {}
    }

    property var filteredModel: sourceInsteadofSink ? sourceModelFiltered : sinkModelFiltered
    property string defaultIconName: plasmoid.configuration.defaultIconName

    function formFactorIcon(device, port, fallback) {
        if (!port) {
            port = {}
        }

        const iconName = device.iconName || device.properties["device.icon_name"] || device.properties["device.icon-name"];
        if (iconName && !/^audio-card/.test(iconName)) {
            return iconName;
        }

        const data = {
            formFactor: device.formFactor || "",
            deviceName: device.name || "",
            portName: port.name || "",
            deviceDescription: device.description || "",
            portDescription: port.description || "",
        }

        data.portName = data.portName.replace(/-[0-9]+$/, "")

        const rules = [
            {
                icon: "audio-card",
                score: 1,
                formFactor: /^internal$/i,
                portName: /^analog-input$|^analog-input-video|^analog-output(-mono)?$/i
            },
            {
                icon: "audio-card",
                score: 1,
                portName: /^analog-input-linein|^analog-output-lineout|^multichannel-input|^multichannel-output/i
            },
            {
                icon: "portable",
                score: 2,
                formFactor: /^portable$/i,
            },
            {
                icon: "computer",
                score: 2,
                formFactor: /^computer$/i,
            },
            {
                icon: "preferences-system-bluetooth",
                score: 2,
                deviceName: /^bluez/i,
            },
            {
                icon: "media-removable-symbolic",
                score: 2,
                deviceName: /^alsa[^.]+\.usb/i,
            },
            {
                icon: "question",
                score: 1,
                deviceName: /^null-/i,
            },
            {
                icon: "audio-speakers-symbolic",
                score: 3,
                formFactor: /^speaker$/i,
                portName: /^analog-output-speaker/i,
            },
            {
                icon: "audio-input-microphone",
                score: 3,
                formFactor: /^microphone$/i,
                portName: /^analog-input-microphone(?!-headset)|analog-input-mic$/i,
            },
            {
                icon: "audio-headphones",
                score: 3,
                formFactor: /^headphone$/i,
                portName: /^analog-output-headphones?|^virtual-surround-7.1/i,
            },
            {
                icon: "audio-headset",
                score: 4,
                formFactor: /^headset$/i,
                portName: /^analog-input-microphone-headset|^analog-chat-(input|output)|^steelseries-arctis/i,
            },
            {
                icon: "phone-symbolic",
                score: 3,
                formFactor: /^phone$/i,
            },
            {
                icon: "handset",
                score: 3,
                formFactor: /^handset$/i,
            },
            {
                icon: "hands-free",
                score: 3,
                formFactor: /^hands-free$/i,
            },
            {
                icon: "tv",
                score: 4,
                formFactor: /^tv$/i,
            },
            {
                icon: "video-display",
                score: 4,
                portName: /^hdmi-output/i,
            },
            {
                icon: "hifi",
                score: 4,
                formFactor: /^hifi$/i,
                portName: /^iec958-/i,
            },
            {
                icon: "audio-radio",
                score: 4,
                portName: /^analog-input-radio/,
            },
            {
                icon: "camera-web",
                score: 4,
                formFactor: /^webcam$/i,
            },
            {
                icon: "car",
                score: 4,
                formFactor: /^car$/i,
            },
        ]

        let icon = fallback || "audio-card"
        let score = 0
        for (const rule of rules) {
            for (const attr of Object.keys(data)) {
                if (rule[attr]) {
                    if (rule[attr].test(data[attr])) {
                        if (rule.score >= score) {
                            icon = rule.icon
                            score = rule.score
                        }
                    }
                }
            }
        }
        return icon
    }

    function getNaming(model, device, port) {
        if (naming !== 0 && naming !== 1 && device.properties) {
            const nick = device.properties["node.nick"];
            if (nick) return nick;
        }

        if (naming !== 0 && port) {
            const desc = port.description;
            if (desc) return desc;
        }

        return model.Description;
    }

    GridLayout {
        id: gridLayout
        flow: useVerticalLayout ? GridLayout.TopToBottom : GridLayout.LeftToRight
        anchors.fill: parent

        Repeater {
            model: filteredModel

            delegate: QtControls.ToolButton {
                readonly property var device: model.PulseObject
                readonly property var currentPort: model.Ports[ActivePortIndex]
                readonly property string currentDescription: getNaming(model, device, currentPort)

                id: tab
                enabled: currentPort !== null
                text: labeling !== 2 ? currentDescription + (device.muted ? " (muted)" : "") : ""
                icon.name: labeling !== 1 ? formFactorIcon(device, currentPort, defaultIconName) : ""

                checkable: true
                autoExclusive: true

                // Plasma 6 / Qt 6 fix:
                // Keep the tooltip attached to the button instead of creating
                // a separate ToolTip object whose popup can disturb hover.
                QtControls.ToolTip.visible: hovered
                QtControls.ToolTip.delay: 500
                QtControls.ToolTip.timeout: -1
                QtControls.ToolTip.text: currentDescription

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: -1

                Binding {
                    target: tab
                    property: "checked"
                    value: device.default
                }

                onClicked: {
                    device.default = true
                }
            }
        }
    }
}
