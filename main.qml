import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import QtQuick.Controls.Material 2.12

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Xirac Sample Chart App")

    TabBar {
        id: bar
        width: parent.width
        TabButton {
            text: qsTr("Setup")
        }
        TabButton {
            text: qsTr("Chart")
        }
        TabButton {
            text: qsTr("Control")
        }
    }

    StackLayout {
        width: parent.width
        anchors.top: bar.bottom
        anchors.bottom: parent.bottom
        currentIndex: bar.currentIndex
        // Setup tab
        GridLayout {
            columns: 2

            // URL
            Label {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                text: "Server Address:"
            }
            TextField {
                id: url
                Layout.fillWidth: true
                Layout.rightMargin: 20
                placeholderText: "URL"
                text: "http://192.168.4.50/read-json"
                selectByMouse: true
            }

            // From
            Label {
                Layout.leftMargin: 20
                text: "From Index:"
            }
            TextField {
                id: from
                Layout.rightMargin: 20
                placeholderText: "from"
                text: "1"
                selectByMouse: true
            }

            // To
            Label {
                Layout.leftMargin: 20
                text: "To Index:"
            }
            TextField {
                id: to
                Layout.rightMargin: 20
                placeholderText: "to"
                text: "1000"
                selectByMouse: true
            }

            // Batch mode
            CheckBox {
                id: batchMode
                Layout.columnSpan: 2
                Layout.leftMargin: 20
                text: "Batch Mode"
            }

            // Batch size
            Label {
                Layout.leftMargin: 20
                text: "Batch Size:"
            }
            TextField {
                id: batchSize
                enabled: batchMode.checked
                Layout.rightMargin: 20
                placeholderText: "batch size"
                text: "400"
                selectByMouse: true
            }

            // Bottom buttons
            RowLayout {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                spacing: 20

                Button {
                    highlighted: true
                    text: "Run"
                    onClicked: {
                        lines.clear();
                        bar.currentIndex = 1
                        console.log("From:", from.text, "to:", to.text);

                        if(batchMode.checked) {
                            // Batch mode
                            for(let i = parseInt(from.text); i < parseInt(to.text); i+=parseInt(batchSize.text)) {

                                let req = new XMLHttpRequest();
                                req.open("POST", url.text);
                                req.setRequestHeader("Content-Type", "application/json;charset=UTF-8");

                                req.onreadystatechange = function() {
                                    if (req.readyState == XMLHttpRequest.DONE) {
                                        // what you want to be done when request is successfull
                                        //console.log("req.body", req.responseText)

                                        const chunk = JSON.parse(req.responseText).values
                                        for (const v of chunk) {
                                            lines.insert(v.address, v.address, v.value);
                                        }
                                    }
                                }
                                req.onerror = function(){
                                    // what you want to be done when request failed
                                    console.log("Failed", req.responseText)
                                }

                                req.send(JSON.stringify({"from": i , "to": i + parseInt(batchSize.text) }));
                            }
                        } else {
                            // Normal mode
                            for(let i = from.text; i < to.text; ++i) {
                                let req = new XMLHttpRequest();
                                req.open("POST", url.text);
                                req.setRequestHeader("Content-Type", "application/json;charset=UTF-8");

                                req.onreadystatechange = function() {
                                    if (req.readyState == XMLHttpRequest.DONE) {
                                        // what you want to be done when request is successfull
                                        //console.log("req.body", req.responseText)
                                        lines.insert(i, i, JSON.parse(req.responseText).value)
                                    }
                                }
                                req.onerror = function(){
                                    // what you want to be done when request failed
                                    console.log("Failed", req.responseText)
                                }

                                req.send(JSON.stringify({ "address": i }));
                            }
                        }
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: {
                        lines.clear();
                    }
                }
            }
        }
        // Chart tab
        ChartView {
            antialiasing: true
            LineSeries {
                id: lines
                name: "Received Data"
                axisX: ValueAxis {
                    id: xAxis
                    min: 0
                    max: 4000
                }
                axisY: ValueAxis {
                    id: yAxis
                    min: 0
                    max: 4000
                }
                XYPoint { x: 0; y: 0 }
            }
        }
        // Control tab
        GridLayout {
            columns: 2

            Label {
                Layout.leftMargin: 20
                Layout.rightMargin: 10
                text: "Exposure Time:"
            }

            RowLayout {
                RadioButton {
                    text: "Microsecond"
                }
                RadioButton {
                    text: "Milisecond"
                }
            }

            Label {
                Layout.leftMargin: 20
                text: "Exposure:"
            }

            RowLayout {
                Slider {
                    id: sliderExposure
                    from: 1
                    to: 1000
                    stepSize: 1
                }
                Label{
                    text: sliderExposure.value
                }
            }


            Label {
                Layout.leftMargin: 20
                text: "Parameters:"
            }

            RowLayout {
                CheckBox {
                    text: "Par1"
                }
                CheckBox {
                    text: "Par2"
                }
            }

            RowLayout {
                Layout.columnSpan: 2
                Layout.leftMargin: 20
                Button {
                    highlighted: true
                    text: "Reset"
                }
                Button {
                    text: "Trig"
                }
                Button {
                    text: "Load"
                }
                Button {
                    text: "Chart"
                }
            }
        }
    }
}
