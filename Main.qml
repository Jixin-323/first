import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: rootWindow
    width: 1280
    height: 720
    visible: true
    title: "RoboMaster 比赛界面"
    color: "black"

    // ==============================================
    // 1. 全局数据定义（绑定 C++ 数据）
    // ==============================================
    property int redScore: rmBridge.redScore
    property int blueScore: rmBridge.blueScore
    property int totalSeconds: rmBridge.totalSeconds
    property string backgroundImageSource: "qrc:/cnm/image/sb.png"
    property string mapImageSource: ""

    // 红方血量
    property int redBaseHp: rmBridge.redBaseHp
    property int redSentryHp: rmBridge.redSentryHp
    property int redDroneHp: rmBridge.redDroneHp
    property int redEngineerHp: rmBridge.redEngineerHp
    property int redInfantry1Hp: rmBridge.redInfantry1Hp
    property int redInfantry2Hp: rmBridge.redInfantry2Hp
    property int redHeroHp: rmBridge.redHeroHp

    // 蓝方血量
    property int blueBaseHp: rmBridge.blueBaseHp
    property int blueSentryHp: rmBridge.blueSentryHp
    property int blueDroneHp: rmBridge.blueDroneHp
    property int blueEngineerHp: rmBridge.blueEngineerHp
    property int blueInfantry1Hp: rmBridge.blueInfantry1Hp
    property int blueInfantry2Hp: rmBridge.blueInfantry2Hp
    property int blueHeroHp: rmBridge.blueHeroHp

    // 己方数据
    property int currentRobotHp: rmBridge.robotHp               //血量
    property int currentRobotAmmo: rmBridge.robotAmmo           //子弹
    property real currentHeat: rmBridge.robotHeat               //武器温度
    property real shotv: rmBridge.shotV                         //射击初速度
    property int remainingAmmo: rmBridge.remainingAmmo          //允许发弹量
    property int currentExperience: rmBridge.currentExp         //当前经验
    property int experienceForUpgrade: rmBridge.expToUpgrade    //升级所需经验
    property int currentRobotLevel: rmBridge.robotLevel         //当前等级
    property int chassisType: rmBridge.chassisType              //底盘模式
    property int shooterType: rmBridge.shooterType              //射击模式

    // 窗口标记（用于选择窗口）
    property bool isSelectWindowShowing: false
    property bool isGamePaused: false

    // 记录上一次鼠标坐标（计算速度用）
        property real lastMouseX: 0
        property real lastMouseY: 0


    // ==============================================
    // 2. 背景图传画面
    // ==============================================
    Image {
        anchors.fill: parent
        source: backgroundImageSource
        fillMode: Image.PreserveAspectCrop

        MouseArea {                     //交互（鼠标键盘操作）
            anchors.fill: parent
            z: 10
            hoverEnabled: true   // 允许未按下时也触发鼠标移动
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            //开火处理
            Timer {
                id: autoFireTimer
                interval: 100
                repeat: true
                onTriggered: {
                     if(rootWindow.isGamePaused) return;
                    rmBridge.onFireRequested()
                }
            }

            onPressed:(mouse) => {
                if(rootWindow.isGamePaused) return;

                        var left = false;
                        var right = false;
                        var mid = false;

                        if (mouse.button === Qt.LeftButton) left = true;
                        if (mouse.button === Qt.RightButton) right = true;
                        if (mouse.button === Qt.MiddleButton) mid = true;

                        // 发送真实按键状态
                        rmBridge.onMouseKeyUpdate(left, right, mid);

                        if(left) {
                                    autoFireTimer.start();
                                    rmBridge.onFireRequested();
                                }
            }

            onReleased: (mouse) =>{
                rmBridge.onMouseKeyUpdate(false, false, false);
                autoFireTimer.stop()
            }

            // 鼠标移动处理
            onPositionChanged: (mouse) => {
                if(rootWindow.isGamePaused) return;

                // 1. 计算 鼠标移动速度 (dx, dy) = 当前坐标 - 上一坐标
                var dx = mouse.x - rootWindow.lastMouseX;
                var dy = mouse.y - rootWindow.lastMouseY;

                // 2. 传给C++：传速度(dx,dy)
                rmBridge.onMouseMoved(dx, dy);

                // 3. 更新上一次坐标
                rootWindow.lastMouseX = mouse.x;
                rootWindow.lastMouseY = mouse.y;
            }

            //滚轮处理
            onWheel: (wheel) => {
                    if(rootWindow.isGamePaused) return;
                    // wheel.y 就是滚轮增量：正值=向前，负值=向后 → 完美匹配协议
                    rmBridge.onMouseWheel(wheel.angleDelta.y);
                }
        }
    }

    // ==============================================
    // 3. 顶部左侧：红方基地血条+6个战车小血条
    // ==============================================
    Text {
        text: "华南农业大学 Taurus"
        color: "white"
        font.pixelSize: 14
        font.bold: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 5
        anchors.leftMargin: 20
    }
    Rectangle {
        width: 400
        height: 30
        color: "#00000090"
        radius: 5

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20

        Rectangle {
            width: 390
            height: 20
            color: "#333333"
            radius: 3
            border.color: "yellow"
            border.width: 1
            anchors.centerIn: parent

            Rectangle {
                width: Math.min(385, redBaseHp/2000*385)
                height: 18
                color: "#FF0000"
                radius: 2
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: redBaseHp + "/2000"
                color: "#FFFFFF"
                font.pixelSize: 14
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.centerIn: parent
            }
        }
    }

    Row {
        height: 40
        spacing: 5

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 60
        anchors.leftMargin: 20

        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, redSentryHp/1000*63)
                    height: 13
                    color: "#FF0000"
                    radius: 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "哨兵"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, redDroneHp/1000*63)
                    height: 13
                    color: "#FF0000"
                    radius: 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "无人机"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, redEngineerHp/1000*63)
                    height: 13
                    color: "#FF0000"
                    radius: 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "工程"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, redInfantry1Hp/1000*63)
                    height: 13
                    color: "#FF0000"
                    radius: 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "步兵1"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, redInfantry2Hp/1000*63)
                    height: 13
                    color: "#FF0000"
                    radius: 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "步兵2"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, redHeroHp/1000*63)
                    height: 13
                    color: "#FF0000"
                    radius: 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "英雄"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ==============================================
    // 4. 顶部右侧：蓝方基地血条+6个战车小血条
    // ==============================================
    Text {
        text: "华南虎 华南理工大学"
        color: "white"
        font.pixelSize: 14
        font.bold: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.rightMargin: 20
    }
    Rectangle {
        width: 400
        height: 30
        color: "#00000090"
        radius: 5

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20

        Rectangle {
            width: 390
            height: 20
            color: "#333333"
            radius: 3
            border.color: "yellow"
            border.width: 1
            anchors.centerIn: parent

            Rectangle {
                width: Math.min(385, blueBaseHp/2000*385)
                height: 18
                color: "#0066FF"
                radius: 2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: blueBaseHp + "/2000"
                color: "#FFFFFF"
                font.pixelSize: 14
                font.bold: true
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.centerIn: parent
            }
        }
    }

    Row {
        height: 40
        spacing: 5

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 60
        anchors.rightMargin: 20

        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, blueSentryHp/1000*63)
                    height: 13
                    color: "#0066FF"
                    radius: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "哨兵"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, blueDroneHp/1000*63)
                    height: 13
                    color: "#0066FF"
                    radius: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "无人机"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, blueEngineerHp/1000*63)
                    height: 13
                    color: "#0066FF"
                    radius: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "工程"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, blueInfantry1Hp/1000*63)
                    height: 13
                    color: "#0066FF"
                    radius: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "步兵1"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, blueInfantry2Hp/1000*63)
                    height: 13
                    color: "#0066FF"
                    radius: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Text {
                text: "步兵2"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            spacing: 2
            Rectangle {
                width: 65
                height: 15
                color: "#333333"
                radius: 2
                border.color: "yellow"
                border.width: 1
                Rectangle {
                    width: Math.min(63, blueHeroHp/1000*63)
                    height: 13
                    color: "#0066FF"
                    radius: 1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
           }
            Text {
                text: "英雄"
                color: "#FFFFFF"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ==============================================
    // 5. 比分+倒计时
    // ==============================================
    Rectangle {  //5.1红方分数
        id: redScorePanel
        z: 9998
        width: 60
        height: 45
        color: "#FFFFFF"
        radius: 8
        border.color: "#000000"
        border.width: 2

        anchors.top: parent.top
        anchors.right: countdownPanel.left
        anchors.topMargin: 10
        anchors.rightMargin: 10

        Text {
            text: redScore
            color: "#FF0000"
            font.pixelSize: 24
            font.bold: true
            anchors.centerIn: parent
        }
    }

    Rectangle {  //5.2倒计时
        id: countdownPanel
        z: 9999
        width: 160
        height: 45
        color: "#FFFFFF"
        radius: 8
        border.color: "#000000"
        border.width: 2

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10

        Text {
            id: countdownText
            text: {
                var m = Math.floor(totalSeconds / 60)
                var s = totalSeconds % 60
                var mStr = m < 10 ? "0" + m : "" + m
                var sStr = s < 10 ? "0" + s : "" + s
                return mStr + ":" + sStr
            }
            color: "#000000"
            font.pixelSize: 22
            font.bold: true
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {  //5.3蓝方分数
        id: blueScorePanel
        z: 9998
        width: 60
        height: 45
        color: "#FFFFFF"
        radius: 8
        border.color: "#000000"
        border.width: 2

        anchors.top: parent.top
        anchors.left: countdownPanel.right
        anchors.topMargin: 10
        anchors.leftMargin: 10

        Text {
            text: blueScore
            color: "#0066FF"
            font.pixelSize: 24
            font.bold: true
            anchors.centerIn: parent
        }
    }

    // ==============================================
    // 6. 左下角：己方当前操控机器人面板
    // ==============================================
    Rectangle {
        width: 300
        height: 180
        color: "#00000090"
        radius: 8

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10    // 左右位置不变
        anchors.bottomMargin: 5  // 数值越大，面板越靠下（自己调这个数）

        // 6.1 武器温度
        Text {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.rightMargin: 10
            color: currentHeat <= 20.0 ? "yellow" : "red"
            font.pixelSize: 24
            text: currentHeat.toFixed(3)
        }

        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 40
            anchors.leftMargin: 15
            spacing: 10

            // 6.2 血量
            Column {
                    spacing: 0   //打包在一块
            Text {
                text: "当前血量"
                color: "white"
                font.pixelSize: 12
                font.bold: true
            }
            Rectangle {
                width: 270
                height: 23
                color: "#333333"
                radius: 6
                Rectangle {
                    width: Math.min(265, currentRobotHp/100*265)
                    height: 21
                    color: currentRobotHp > 30 ? "#4CAF50" : "#FF5252"
                    radius: 5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        running: currentRobotHp <= 30
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.4; duration: 500 }
                        NumberAnimation { to: 1; duration: 500 }
                    }
                }
                Text {
                    text:currentRobotHp + "%"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.centerIn: parent
                }
            }
            }

            // 6.3 经验
            Rectangle {
                // 总宽度和血条、弹条保持一致（270），保证右侧对齐
                width: 270
                height: 13
                color: "transparent" // 透明背景，不破坏面板

                //等级文字：放在经验条左侧空白处
                Text {
                    text: "LV." + currentRobotLevel
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left // 贴左侧
                }
                  Rectangle {
                       width: 240
                       height: 13
                       color: "#333333"
                       radius: 6
                       anchors.right: parent.right
                       anchors.verticalCenter: parent.verticalCenter
                         Rectangle {
                          width: (currentExperience + experienceForUpgrade) == 0 ? 0 : Math.min(238, (currentExperience / (currentExperience + experienceForUpgrade)) * 238)
                          height: 12
                          color: "#9C27B0"
                          radius: 5
                          anchors.left: parent.left
                          anchors.verticalCenter: parent.verticalCenter
                          anchors.leftMargin: 1
                      }
                     Text {
                         text: "仍需: " + experienceForUpgrade + " 经验"
                         color: "#FFFFFF"
                         font.pixelSize: 11
                         font.bold: true
                         anchors.right: parent.right
                         anchors.rightMargin: 5
                         anchors.centerIn: parent
                    }
                }
            }

            // 6.4 弹量
            Rectangle {
                width: 270
                height: 12
                color: "#333333"
                radius: 6
                Rectangle {
                    width: Math.min(265, currentRobotAmmo/200*265)
                    height: 11
                    color: "#FFC107"
                    radius: 5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "当前弹量:"+currentRobotAmmo + "/200"
                    color: "#FFFFFF"
                    font.pixelSize: 10
                    font.bold: true
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.centerIn: parent
                }
            }

            // 6.5 底盘+发射模式调整小按钮
            Row {
                spacing: 10
                anchors.left: parent.left
                // 底盘按钮
                Rectangle {
                    width: 60
                    height: 25
                    color: "#333333"
                    border.color: "#FFFFFF"
                    border.width: 1
                    radius: 4
                    Text {
                        text: chassisType === 1 ? "底盘(血量)" : "底盘(功率)"
                        color: "#FFFFFF"
                        font.pixelSize: 10
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!isSelectWindowShowing) {
                                isSelectWindowShowing = true
                                chassisSelectWindow.visible = true
                            }
                        }
                    }
                }
                // 发射按钮
                Rectangle {
                    width: 60
                    height: 25
                    color: "#333333"
                    border.color: "#FFFFFF"
                    border.width: 1
                    radius: 4
                    Text {
                        text: shooterType === 1 ? "发射(冷却)" : "发射(爆发)"
                        color: "#FFFFFF"
                        font.pixelSize: 10
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!isSelectWindowShowing) {
                                isSelectWindowShowing = true
                                shooterSelectWindow.visible = true
                            }
                        }
                    }
                }
            }
        }
    }

    // ==============================================
    // 7.1 底盘选择窗口
    // ==============================================
    Rectangle {
        id: chassisSelectWindow
        z: 999
        width: 250
        height: 140
        color: "#000000"
        border.color: "#FFFFFF"
        border.width: 1
        radius: 6
        anchors.centerIn: parent
        visible: false
        opacity: 0.9

        Column {
            spacing: 5
            anchors.centerIn: parent
            Text {
                text: "血量优先"
                color: chassisType === 1 ? "#4CAF50" : "#FFFFFF"
                font.pixelSize: 30
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        rmBridge.setChassisType(1)
                        chassisSelectWindow.visible = false
                        isSelectWindowShowing = false
                    }
                }
            }
            Text {
                text: "功率优先"
                color: chassisType === 2 ? "#4CAF50" : "#FFFFFF"
                font.pixelSize: 30
                MouseArea {
                    anchors.fill: parent
                    enabled: !rootWindow.isGamePaused
                    onClicked: {
                        rmBridge.setChassisType(2)
                        chassisSelectWindow.visible = false
                        isSelectWindowShowing = false
                    }
                }
            }
        }
    }

    // ==============================================
    // 7.2. 发射选择窗口
    // ==============================================
    Rectangle {
        id: shooterSelectWindow
        z: 999
        width: 250
        height: 140
        color: "#000000"
        border.color: "#FFFFFF"
        border.width: 1
        radius: 6
        anchors.centerIn: parent
        visible: false
        opacity: 0.9

        Column {
            spacing: 5
            anchors.centerIn: parent
            Text {
                text: "冷却优先"
                color: shooterType === 1 ? "red" : "#FFFFFF"
                font.pixelSize: 30
                MouseArea {
                    anchors.fill: parent
                    enabled: !rootWindow.isGamePaused
                    onClicked: {
                        rmBridge.setShooterType(1)
                        shooterSelectWindow.visible = false
                        isSelectWindowShowing = false
                    }
                }
            }
            Text {
                text: "爆发优先"
                color: shooterType === 2 ? "red" : "#FFFFFF"
                font.pixelSize: 30
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        rmBridge.setShooterType(2)
                        shooterSelectWindow.visible = false
                        isSelectWindowShowing = false
                    }
                }
            }
        }
    }

    // ==============================================
    // 7.3. 点空白关闭窗口
    // ==============================================
    MouseArea {
        anchors.fill: parent
        enabled: isSelectWindowShowing && !rootWindow.isGamePaused
        onClicked: {
            chassisSelectWindow.visible = false
            shooterSelectWindow.visible = false
            isSelectWindowShowing = false
        }
        z: 998
    }



    // ==============================================
    // 8. 右下角：是否脱战+小地图框
    // ==============================================
    //8.1是否脱战
    Text {
        id: combatStatusText
        // 锚定：小地图的正上方
        anchors.bottom: mapPanel.top
        anchors.horizontalCenter: mapPanel.horizontalCenter
        anchors.bottomMargin: 6
        font.pixelSize: 18
        font.bold: true

        text: rmBridge.isOutOfCombat ? "脱战" : "战斗中"
        color: rmBridge.isOutOfCombat ? "#2ECC71" : "#FF4444"
    }
    //8.2小地图
    Rectangle {
        id: mapPanel
        z: 50
        width: 250
        height: 120
        color: "#FFFFFF"
        radius: 8
        border.color: "#000000"
        border.width: 2

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 30

        Text {
            text: "小地图"
            color: "#000000"
            font.pixelSize: 24
            font.bold: true
            anchors.centerIn: parent
        }
    }

    // ==============================================
    // 9 射击初速度+允许发弹量+缓冲能量
    // ==============================================
    Item {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 400
        z: 999
        Column {
            spacing: 2
            Text {
                color: "#FFFFFF"
                font.pixelSize: 10
                text: "射击初速度"
            }
            Text {
                color: "#FFFFFF"
                font.pixelSize: 15
                text: " " + shotv
            }
            Text {
                color: "#FFFFFF"
                font.pixelSize: 10
                text: "允许发弹量"
            }
            Text {
                color: "#FFFFFF"
                font.pixelSize: 15
                text: "  " + remainingAmmo
            }
        }
    }
    //缓冲能量
    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 15      // 左边留白，不贴边
        font.pixelSize: 22
        font.bold: true
        color: "#FFFFFF"

        text: "缓冲能量：" + rmBridge.bufferEnergy
    }


    // ==============================================
    // 10. 暂停窗口
    // ==============================================
    Rectangle {
        id: pauseWindow
        width: rootWindow.width * 0.8
        height: rootWindow.height * 0.8
        color: "#FFFFFF"
        radius: 8
        anchors.centerIn: parent
        // 绑定暂停开关
        visible: rootWindow.isGamePaused
        z: 1000 // 置顶所有界面

        Text {
            text: "比赛暂停"
            color: "#000000"
            font.pixelSize: 120
            font.weight: Font.Bold
            anchors.centerIn: parent
        }
        Text {
            text: "按 ESC 继续比赛"
            color: "#666666"
            font.pixelSize: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // ESC 键盘控制（唯一生效的按键）
    Item {
        anchors.fill: parent
        focus: true
        z: -1
        // 按ESC切换暂停/运行
        Keys.onEscapePressed: {
            rootWindow.isGamePaused = !rootWindow.isGamePaused
            // 通知C++子线程暂停/恢复
            rmBridge.togglePause()
        }
        Component.onCompleted: forceActiveFocus()
    }


    // ==============================================
    // 11. 受击闪红画面
    // ==============================================
    //11.1画面
    Rectangle {
        id: hitEffect
        anchors.fill: parent
        color: "red"
        opacity: 0
        z: 999

        SequentialAnimation on opacity {
            id: normalHitAnimation
            NumberAnimation { to: 0.25; duration: 60 }
            NumberAnimation { to: 0; duration: 250 }
        }

        SequentialAnimation on opacity {
            id: lowHpHitAnimation
            NumberAnimation { to: 0.5; duration: 80 }
            NumberAnimation { to: 0.1; duration: 150 }
            NumberAnimation { to: 0.4; duration: 80 }
            NumberAnimation { to: 0; duration: 300 }
        }

        SequentialAnimation on x {
            id: shakeAnimation
            NumberAnimation { to: -10; duration: 50 }
            NumberAnimation { to: 10; duration: 50 }
            NumberAnimation { to: 0; duration: 50 }
        }
    }


    // 11.2 受击动画监听（监听血量变化触发）
    onCurrentRobotHpChanged: {
        if (currentRobotHp > 30) {
            normalHitAnimation.start()
        } else {
            lowHpHitAnimation.start()
            shakeAnimation.start()
        }
    }


}//这里是window的  ‘}’
