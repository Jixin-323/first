#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> // 关键：给QML设置上下文属性需要这个头文件
#include "rmbridge.h" // 引入我们写的RMBridge头文件

int main(int argc, char *argv[])
{
    // 1. 创建Qt应用程序对象（所有Qt程序的入口）
    QGuiApplication app(argc, argv);

    // 2. 创建RMBridge实例（核心：数据桥接类）
    RMBridge rmBridge;

    // 3. 创建QML引擎
    QQmlApplicationEngine engine;

    // 4. 关键：把RMBridge实例暴露给QML，命名为"rmBridge"
    // QML里可以直接用rmBridge.xxx访问属性/调用函数
    engine.rootContext()->setContextProperty("rmBridge", &rmBridge);

    // 5. 加载你的QML界面文件
     const QUrl url("qrc:/qt/qml/RM/Main.qml");

    // 6. 绑定QML加载完成的信号（可选，保证程序稳定）
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [&](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    // 7. 加载QML文件
    engine.load(url);

    // 8. 运行应用程序
    return app.exec();
}
