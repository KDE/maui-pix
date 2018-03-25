#include "pix.h"
#include "db/fileloader.h"
#include <QFileSystemWatcher>
#include <QTimer>
#include <QApplication>
#include <QDesktopWidget>
#include <QDirIterator>
#include <QtQml>
#include <QPalette>
#include <QWidget>
#include <QColor>

using namespace PIX;

Pix::Pix(QObject *parent) : DBActions(parent)
{
    qDebug() << "Getting settings info from: " << PIX::SettingPath;

    //    if(!PIX::fileExists(notifyDir+"/Pix.notifyrc"))
    //    {
    //        qDebug()<<"The Knotify file does not exists, going to create it";
    //        QFile knotify(":Data/data/Pix.notifyrc");

    //        if(knotify.copy(notifyDir+"/Pix.notifyrc"))
    //            qDebug()<<"the knotify file got copied";
    //    }


    this->fileLoader = new FileLoader;

    connect(this, &Pix::populate, this, &Pix::populateDB);

    connect(this->fileLoader, &FileLoader::finished,[this]()
    {
        emit refreshTables({{PIX::TABLEMAP[TABLE::ALBUMS], true},
                            {PIX::TABLEMAP[TABLE::TAGS], true},
                            {PIX::TABLEMAP[TABLE::IMAGES], true}});
    });

    emit this->populate(PIX::PicturesPath);
}

Pix::~Pix()
{
    delete this->fileLoader;
}

QVariantList Pix::getList(const QStringList &urls)
{
    QVariantList mapList;

    for(auto url : urls)
    {
        auto queryTxt = QString("SELECT * FROM %1 WHERE %2 = \"%3\"").arg(TABLEMAP[TABLE::IMAGES],
                KEYMAP[KEY::URL], url);

        mapList << this->get(queryTxt);
    }

    return mapList;
}


bool Pix::run(const QString &query)
{
    return this->execQuery(query);
}

void Pix::populateDB(const QString &path)
{
    qDebug() << "Function Name: " << Q_FUNC_INFO
             << "new path for database action: " << path;
    auto newPath = path;

    if(path.startsWith("file://"))
        newPath = newPath.replace("file://", "");
    fileLoader->requestPath(newPath);
}

QString Pix::backgroundColor()
{
#if defined(Q_OS_ANDROID)
    return "#31363b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Background).name();
#elif defined(Q_OS_WIN32)
    return "#31363b";
#endif
}

QString Pix::foregroundColor()
{
#if defined(Q_OS_ANDROID)
    return "#FFF";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Text).name();
#elif defined(Q_OS_WIN32)
    return "#FFF";
#endif
}

QString Pix::hightlightColor()
{
#if defined(Q_OS_ANDROID)
    return "";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Highlight).name();
#elif defined(Q_OS_WIN32)
    return "";
#endif
}

QString Pix::midColor()
{
#if defined(Q_OS_ANDROID)
    return "#31363b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Midlight).name();
#elif defined(Q_OS_WIN32)
    return "#31363b";
#endif
}

QString Pix::altColor()
{
#if defined(Q_OS_ANDROID)
    return "#232629";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Base).name();
#elif defined(Q_OS_WIN32)
    return "#232629";
#endif
}

QString Pix::pixColor()
{
    return "#03A9F4";
}

bool Pix::isMobile()
{
    return PIX::isMobile();
}

int Pix::screenGeometry(QString &side)
{
    side = side.toLower();
    auto geo = QApplication::desktop()->screenGeometry();

    if(side == "width")
        return geo.width();
    else if(side == "height")
        return geo.height();
    else return 0;
}

int Pix::cursorPos(QString &axis)
{
    axis = axis.toLower();
    auto pos = QCursor::pos();
    if(axis == "x")
        return pos.x();
    else if(axis == "y")
        return pos.y();
    else return 0;
}

QString Pix::homeDir()
{
    return PIX::PicturesPath;
}

QVariantList Pix::getDirs(const QString &pathUrl)
{
    auto path = pathUrl;
    if(path.startsWith("file://"))
        path.replace("file://", "");
    qDebug()<<"DIRECTRORY"<<path;
    QVariantList paths;

    if (QFileInfo(path).isDir())
    {
        QDirIterator it(path, QDir::Dirs, QDirIterator::NoIteratorFlags);
        while (it.hasNext())
        {
            auto url = it.next();
            auto name = QDir(url).dirName();
            qDebug()<<name<<url;
            QVariantMap map = { {"url", url }, {"name", name} };
            paths << map;
        }
    }

    return paths;
}

QVariantMap Pix::getParentDir(const QString &path)
{
    auto dir = QDir(path);
    dir.cdUp();
    auto dirPath = dir.absolutePath();

    if(dir.isReadable() && !dir.isRoot() && dir.exists())
        return {{"url", dirPath}, {"name", dir.dirName()}};
    else
        return {{"url", path}, {"name", QFileInfo(path).dir().dirName()}};

}



