#include "rmbridge.h"
#include <QRandomGenerator>
#include <QDebug>
#include <qthread.h>

// ==================== DataGenerator 子线程实现 ====================
DataGenerator::DataGenerator(QObject *parent)
    : QObject(parent)
{
    // 子线程定时器：每秒生成一次数据
    m_dataTimer = new QTimer(this);
    m_dataTimer->setInterval(1000);
    connect(m_dataTimer, &QTimer::timeout, this, &DataGenerator::generateData);
    m_dataTimer->start();
}

// 【子线程核心逻辑】所有数据计算都在这里运行
void DataGenerator::generateData()
{
    // ============== 模拟所有数据变化 ==============
    static int redScore = 2;
    static int blueScore = 1;
    static int totalSeconds = 180;

    static int redBaseHp = 2000;
    static int redSentryHp = 1000, redDroneHp = 1000, redEngineerHp = 1000;
    static int redInfantry1Hp = 1000, redInfantry2Hp = 1000, redHeroHp = 1000;

    static int blueBaseHp = 2000;
    static int blueSentryHp = 1000, blueDroneHp = 1000, blueEngineerHp = 1000;
    static int blueInfantry1Hp = 1000, blueInfantry2Hp = 1000, blueHeroHp = 1000;

    static int robotHp = 100, robotAmmo = 200;
    static double robotHeat = 20.567, shotV = 13.14;
    static int remainingAmmo = 520;

    static int currentExp = 200, expToUpgrade = 300,robotLevel=1;
    static int chassisType = 1, shooterType = 1;
    static bool isOutOfCombat = false;
    static int bufferEnergy=66;

    // 倒计时
    if (totalSeconds > 0) totalSeconds--;

    // 红方扣血
    redBaseHp = std::max(0, redBaseHp - 13);
    redSentryHp = std::max(0, redSentryHp - (int)(QRandomGenerator::global()->bounded(30)));
    redDroneHp = std::max(0, redDroneHp - (int)(QRandomGenerator::global()->bounded(20)));
    redEngineerHp = std::max(0, redEngineerHp - (int)(QRandomGenerator::global()->bounded(25)));
    redInfantry1Hp = std::max(0, redInfantry1Hp - (int)(QRandomGenerator::global()->bounded(35)));
    redInfantry2Hp = std::max(0, redInfantry2Hp - (int)(QRandomGenerator::global()->bounded(35)));
    redHeroHp = std::max(0, redHeroHp - (int)(QRandomGenerator::global()->bounded(40)));

    // 蓝方扣血
    blueBaseHp = std::max(0, blueBaseHp - 14);
    blueSentryHp = std::max(0, blueSentryHp - (int)(QRandomGenerator::global()->bounded(25)));
    blueDroneHp = std::max(0, blueDroneHp - (int)(QRandomGenerator::global()->bounded(15)));
    blueEngineerHp = std::max(0, blueEngineerHp - (int)(QRandomGenerator::global()->bounded(20)));
    blueInfantry1Hp = std::max(0, blueInfantry1Hp - (int)(QRandomGenerator::global()->bounded(30)));
    blueInfantry2Hp = std::max(0, blueInfantry2Hp - (int)(QRandomGenerator::global()->bounded(30)));
    blueHeroHp = std::max(0, blueHeroHp - (int)(QRandomGenerator::global()->bounded(35)));

    // 热量随机 0~30
    robotHeat = QRandomGenerator::global()->generateDouble() * 30.0;//用bounded可能不兼容
    // 随机掉血
    if (QRandomGenerator::global()->bounded(100) < 30) {
        robotHp = std::max(0, robotHp - (QRandomGenerator::global()->bounded(5) + 1));
    }
    // 经验升级 + 等级系统（最终修复版）
    if (expToUpgrade > 0) {
        int gain = QRandomGenerator::global()->bounded(5, 105);
        currentExp += gain;
        expToUpgrade -= gain;
    }

    // 经验满 -> 立即升级，无卡顿，多余经验保留
    if (expToUpgrade <= 0) {
        // 等级+1
        robotLevel++;
        // 计算溢出的经验
        int extra = abs(expToUpgrade);
        // 新的升级经验
        expToUpgrade = 300 + 100*(robotLevel-1)-extra;
        // 溢出经验留给下一级
        currentExp = extra;
    }

    // 发送数据给主线程
    emit dataUpdateFinished(
        redScore, blueScore, totalSeconds,
        redBaseHp, redSentryHp, redDroneHp, redEngineerHp,
        redInfantry1Hp, redInfantry2Hp, redHeroHp,
        blueBaseHp, blueSentryHp, blueDroneHp, blueEngineerHp,
        blueInfantry1Hp, blueInfantry2Hp, blueHeroHp,
        robotHp, robotAmmo, robotHeat, shotV, remainingAmmo,
        currentExp, expToUpgrade, robotLevel,chassisType, shooterType,isOutOfCombat,bufferEnergy
        );
}



// ==================== RMBridge 主线程实现 ====================
RMBridge::RMBridge(QObject *parent)
    : QObject(parent)
{
    // 1. 创建子线程和工作对象
    m_dataThread = new QThread(this);
    m_generator = new DataGenerator();

    // 2. 将数据生成对象移动到子线程
    m_generator->moveToThread(m_dataThread);

    // 3. 绑定信号槽：子线程数据 → 主线程更新
    connect(m_generator, &DataGenerator::dataUpdateFinished,
            this, &RMBridge::updateAllData);

    // 4. 启动子线程
    m_dataThread->start();

    qDebug() << "数据生成子线程已启动！";
}

RMBridge::~RMBridge()
{
    // 安全退出子线程
    m_dataThread->quit();
    m_dataThread->wait();
    delete m_generator;
}

// 接收子线程数据，更新主线程变量（线程安全）
void RMBridge::updateAllData(
    int redScore, int blueScore, int totalSeconds,
    int redBaseHp, int redSentryHp, int redDroneHp, int redEngineerHp,
    int redInfantry1Hp, int redInfantry2Hp, int redHeroHp,
    int blueBaseHp, int blueSentryHp, int blueDroneHp, int blueEngineerHp,
    int blueInfantry1Hp, int blueInfantry2Hp, int blueHeroHp,
    int robotHp, int robotAmmo, double robotHeat, double shotV, int remainingAmmo,
    int currentExp, int expToUpgrade,int robotLevel, int chassisType, int shooterType,
    bool isOutOfCombat,int bufferEnergy)
{
    m_redScore = redScore;
    m_blueScore = blueScore;
    m_totalSeconds = totalSeconds;

    m_redBaseHp = redBaseHp;
    m_redSentryHp = redSentryHp;
    m_redDroneHp = redDroneHp;
    m_redEngineerHp = redEngineerHp;
    m_redInfantry1Hp = redInfantry1Hp;
    m_redInfantry2Hp = redInfantry2Hp;
    m_redHeroHp = redHeroHp;

    m_blueBaseHp = blueBaseHp;
    m_blueSentryHp = blueSentryHp;
    m_blueDroneHp = blueDroneHp;
    m_blueEngineerHp = blueEngineerHp;
    m_blueInfantry1Hp = blueInfantry1Hp;
    m_blueInfantry2Hp = blueInfantry2Hp;
    m_blueHeroHp = blueHeroHp;

    m_robotHp = robotHp;
    //m_robotAmmo = robotAmmo;  这样开火才会扣子弹，不然子线程一直传过来200
    m_robotHeat = robotHeat;
    m_shotV = shotV;
    m_remainingAmmo = remainingAmmo;

    m_currentExp = currentExp;
    m_expToUpgrade = expToUpgrade;
    m_robotLevel = robotLevel;
    //m_chassisType = chassisType;  这样改完才不会被初始覆盖
    //m_shooterType = shooterType;  这样改完才不会被初始覆盖
    m_bufferEnergy=bufferEnergy;

    // 通知QML刷新
    emit dataUpdated();
}

// 开火逻辑
void RMBridge::onFireRequested()
{
    if (m_isGamePaused) return;
    if (m_robotAmmo > 0) {
        m_robotAmmo--;
        qDebug() << "[操作指令] 鼠标左键开火，剩余子弹:" << m_robotAmmo-1;
        emit dataUpdated();
    }
    else {
        qDebug() << "[操作指令] 子弹耗尽，无法开火";
    }
}

// 设置底盘模式
void RMBridge::setChassisType(int type)
{
    if (m_isGamePaused) return;
    m_chassisType = type;
    QString mode = (type == 1) ? "血量优先" : "功率优先";
    qDebug() << "[控件交互] 切换底盘模式:" << type << "(" << mode << ")";
    emit dataUpdated();
}

// 设置发射模式
void RMBridge::setShooterType(int type)
{
    if (m_isGamePaused) return;
    m_shooterType = type;
    QString mode = (type == 1) ? "冷却优先" : "爆发优先";
    qDebug() << "[控件交互] 切换发射模式:" << type << "(" << mode << ")";
    emit dataUpdated();
}

//鼠标移动速度
void RMBridge::onMouseMoved(int mouse_x, int mouse_y)
{
    if (m_isGamePaused) return;

    // 节流：50ms内只响应一次
    if (!m_lastMouseMoveTimer.isValid()) {
        m_lastMouseMoveTimer.start();
    } else {
        if (m_lastMouseMoveTimer.elapsed() < 50) {
            return;
        }
        m_lastMouseMoveTimer.restart();
    }

    qDebug() << "[操作指令] 鼠标移动速度: X=" << mouse_x << " Y=" << mouse_y;
}

// 滚轮速度
void RMBridge::onMouseWheel(int mouse_z)
{
    if (m_isGamePaused) return;

    // 节流（和鼠标移动保持一致）
    if (!m_lastMouseMoveTimer.isValid()) {
        m_lastMouseMoveTimer.start();
    } else {
        if (m_lastMouseMoveTimer.elapsed() < 50) {
            return;
        }
        m_lastMouseMoveTimer.restart();
    }

    // 打印日志验证
    qDebug() << "[操作指令] 滚轮速度: Z=" << mouse_z;
}

//左中右键
void RMBridge::onMouseKeyUpdate(bool left_down, bool right_down, bool mid_down)
{
    if(m_isGamePaused) return;

    // 和鼠标共用节流 50ms
    if (!m_lastMouseMoveTimer.isValid()) {
        m_lastMouseMoveTimer.start();
    } else {
        if (m_lastMouseMoveTimer.elapsed() < 50) return;
        m_lastMouseMoveTimer.restart();
    }

    if(left_down || right_down || mid_down) {
        qDebug() << "鼠标按键：左键=" << left_down
                 << "中键=" << mid_down
                 << "右键=" << right_down;
    }
}


// 暂停
void RMBridge::togglePause()
{
    m_isGamePaused = !m_isGamePaused;
    qDebug() << "[控件交互] 游戏" << (m_isGamePaused ? "已暂停" : "已恢复");
    if (m_isGamePaused) {
        // 暂停：停止子线程定时器
        QMetaObject::invokeMethod(m_generator, "stopTimer");
    } else {
        // 恢复：启动子线程定时器
        QMetaObject::invokeMethod(m_generator, "startTimer");
    }
    emit pauseToggled(m_isGamePaused);
}
