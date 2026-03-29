#ifndef RMBRIDGE_H
#define RMBRIDGE_H

#include <QObject>
#include <QThread>
#include <QTimer>
#include <QElapsedTimer>

// ==================== 子线程数据生成类（工作对象）====================
class DataGenerator : public QObject
{
    Q_OBJECT
public:
    explicit DataGenerator(QObject *parent = nullptr);

    // 👇 新增：子线程定时器启停（控制暂停）
public slots:
    void stopTimer() { m_dataTimer->stop(); }
    void startTimer() { m_dataTimer->start(); }

signals:
    // 子线程计算完成后，发送所有数据给主线程（炒完的菜）
    void dataUpdateFinished(
        int redScore, int blueScore, int totalSeconds,
        int redBaseHp, int redSentryHp, int redDroneHp, int redEngineerHp,
        int redInfantry1Hp, int redInfantry2Hp, int redHeroHp,
        int blueBaseHp, int blueSentryHp, int blueDroneHp, int blueEngineerHp,
        int blueInfantry1Hp, int blueInfantry2Hp, int blueHeroHp,
        int robotHp, int robotAmmo, double robotHeat, double shotV, int remainingAmmo,
        int currentExp, int expToUpgrade,int robotLevel ,int chassisType, int shooterType,
        bool isOutOfCombat,int bufferEnergy
        );

private slots:
    // 子线程定时生成数据（核心逻辑）
    void generateData();

private:
    QTimer *m_dataTimer; // 子线程内的定时器
};

// ==================== 主线程UI桥接类 ====================
class RMBridge : public QObject
{
    Q_OBJECT
    //下面作用：把 C++ 里的变量，开放给 QML 界面使用（暴露）
    Q_PROPERTY(bool isGamePaused READ isGamePaused NOTIFY pauseToggled)//暂停

    Q_PROPERTY(int redScore READ redScore NOTIFY dataUpdated)
    Q_PROPERTY(int blueScore READ blueScore NOTIFY dataUpdated)
    Q_PROPERTY(int totalSeconds READ totalSeconds NOTIFY dataUpdated)

    Q_PROPERTY(int redBaseHp READ redBaseHp NOTIFY dataUpdated)
    Q_PROPERTY(int redSentryHp READ redSentryHp NOTIFY dataUpdated)
    Q_PROPERTY(int redDroneHp READ redDroneHp NOTIFY dataUpdated)
    Q_PROPERTY(int redEngineerHp READ redEngineerHp NOTIFY dataUpdated)
    Q_PROPERTY(int redInfantry1Hp READ redInfantry1Hp NOTIFY dataUpdated)
    Q_PROPERTY(int redInfantry2Hp READ redInfantry2Hp NOTIFY dataUpdated)
    Q_PROPERTY(int redHeroHp READ redHeroHp NOTIFY dataUpdated)

    Q_PROPERTY(int blueBaseHp READ blueBaseHp NOTIFY dataUpdated)
    Q_PROPERTY(int blueSentryHp READ blueSentryHp NOTIFY dataUpdated)
    Q_PROPERTY(int blueDroneHp READ blueDroneHp NOTIFY dataUpdated)
    Q_PROPERTY(int blueEngineerHp READ blueEngineerHp NOTIFY dataUpdated)
    Q_PROPERTY(int blueInfantry1Hp READ blueInfantry1Hp NOTIFY dataUpdated)
    Q_PROPERTY(int blueInfantry2Hp READ blueInfantry2Hp NOTIFY dataUpdated)
    Q_PROPERTY(int blueHeroHp READ blueHeroHp NOTIFY dataUpdated)

    Q_PROPERTY(int robotHp READ robotHp NOTIFY dataUpdated)                //血量
    Q_PROPERTY(int robotAmmo READ robotAmmo NOTIFY dataUpdated)            //子弹
    Q_PROPERTY(double robotHeat READ robotHeat NOTIFY dataUpdated)         //武器温度
    Q_PROPERTY(double shotV READ shotV NOTIFY dataUpdated)                 //射击初速度
    Q_PROPERTY(int remainingAmmo READ remainingAmmo NOTIFY dataUpdated)    //允许发弹量
    Q_PROPERTY(int currentExp READ currentExp NOTIFY dataUpdated)          //当前经验
    Q_PROPERTY(int expToUpgrade READ expToUpgrade NOTIFY dataUpdated)      //仍需经验
    Q_PROPERTY(int robotLevel READ robotLevel NOTIFY dataUpdated)          //当前等级
    Q_PROPERTY(int chassisType READ chassisType NOTIFY dataUpdated)        //底盘模式
    Q_PROPERTY(int shooterType READ shooterType NOTIFY dataUpdated)        //射击模式
    Q_PROPERTY(bool isOutOfCombat READ isOutOfCombat NOTIFY dataUpdated)   //是否脱战
    Q_PROPERTY(int bufferEnergy READ bufferEnergy NOTIFY dataUpdated)      //缓冲能量


public:
    explicit RMBridge(QObject *parent = nullptr);
    ~RMBridge() override;

    //暂停相关
    bool isGamePaused() const { return m_isGamePaused; }
    bool m_isGamePaused = false;


    // 下面都是函数，理解为读取工具，因为QML界面不能直接碰 C++ 里的 m_redScore（盘子接菜）
    int redScore() const { return m_redScore; }
    int blueScore() const { return m_blueScore; }
    int totalSeconds() const { return m_totalSeconds; }
    int redBaseHp() const { return m_redBaseHp; }
    int redSentryHp() const { return m_redSentryHp; }
    int redDroneHp() const { return m_redDroneHp; }
    int redEngineerHp() const { return m_redEngineerHp; }
    int redInfantry1Hp() const { return m_redInfantry1Hp; }
    int redInfantry2Hp() const { return m_redInfantry2Hp; }
    int redHeroHp() const { return m_redHeroHp; }
    int blueBaseHp() const { return m_blueBaseHp; }
    int blueSentryHp() const { return m_blueSentryHp; }
    int blueDroneHp() const { return m_blueDroneHp; }
    int blueEngineerHp() const { return m_blueEngineerHp; }
    int blueInfantry1Hp() const { return m_blueInfantry1Hp; }
    int blueInfantry2Hp() const { return m_blueInfantry2Hp; }
    int blueHeroHp() const { return m_blueHeroHp; }
    int robotHp() const { return m_robotHp; }
    int robotAmmo() const { return m_robotAmmo; }
    double robotHeat() const { return m_robotHeat; }
    double shotV() const { return m_shotV; }
    int remainingAmmo() const { return m_remainingAmmo; }
    int currentExp() const { return m_currentExp; }
    int expToUpgrade() const { return m_expToUpgrade; }
    int robotLevel() const { return m_robotLevel; }
    int chassisType() const { return m_chassisType; }
    int shooterType() const { return m_shooterType; }
    bool isOutOfCombat() const { return m_isOutOfCombat; }
    int bufferEnergy() const { return m_bufferEnergy; }

signals:
    void dataUpdated();              // 通知QML刷新
    void pauseToggled(bool paused);  // 暂停信号


public slots:
    void togglePause();                           // 暂停
    void onFireRequested();                       // 开火
    void setChassisType(int type);                // 设置底盘模式
    void setShooterType(int type);                // 设置发射模式
    void onMouseMoved(int mouse_x, int mouse_y);  // 鼠标移动槽
    void onMouseWheel(int mouse_z);               //滚轮
    void onMouseKeyUpdate(bool left_down, bool right_down, bool mid_down);//左中右

    // 接收子线程发来的最新数据（接到的菜）
    void updateAllData(
        int redScore, int blueScore, int totalSeconds,
        int redBaseHp, int redSentryHp, int redDroneHp, int redEngineerHp,
        int redInfantry1Hp, int redInfantry2Hp, int redHeroHp,
        int blueBaseHp, int blueSentryHp, int blueDroneHp, int blueEngineerHp,
        int blueInfantry1Hp, int blueInfantry2Hp, int blueHeroHp,
        int robotHp, int robotAmmo, double robotHeat, double shotV, int remainingAmmo,
        int currentExp, int expToUpgrade, int robotLevel, int chassisType, int shooterType,
        bool isOutOfCombat,int bufferEnergy
        );

private:
    // 服务员控制厨师和厨房
    QThread *m_dataThread;
    DataGenerator *m_generator;

    QElapsedTimer m_lastMouseMoveTimer;  //记录上次鼠标移动时间（用于节流处理快速操作）

    // 所有比赛数据
    int m_redScore = 2;
    int m_blueScore = 1;
    int m_totalSeconds = 180;

    int m_redBaseHp = 2000;
    int m_redSentryHp = 1000;
    int m_redDroneHp = 1000;
    int m_redEngineerHp = 1000;
    int m_redInfantry1Hp = 1000;
    int m_redInfantry2Hp = 1000;
    int m_redHeroHp = 1000;

    int m_blueBaseHp = 2000;
    int m_blueSentryHp = 1000;
    int m_blueDroneHp = 1000;
    int m_blueEngineerHp = 1000;
    int m_blueInfantry1Hp = 1000;
    int m_blueInfantry2Hp = 1000;
    int m_blueHeroHp = 1000;

    int m_robotHp = 100;
    int m_robotAmmo = 200;
    double m_robotHeat = 20.567;
    double m_shotV = 13.14;
    int m_remainingAmmo = 520;

    int m_currentExp = 200;
    int m_expToUpgrade = 300;
    int m_robotLevel = 1;
    int m_chassisType = 1;
    int m_shooterType = 1;
    bool m_isOutOfCombat = false;
    int m_bufferEnergy = 66;
};

#endif // RMBRIDGE_H
