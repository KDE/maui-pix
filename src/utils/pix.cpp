#include "pix.h"
#include "../db/fileloader.h"
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

Pix::Pix(QObject *parent) : QObject(parent)
{
    qDebug() << "Getting collectionDB info from: " << PIX::CollectionDBPath;
    qDebug() << "Getting settings info from: " << PIX::SettingPath;
    qDebug() << "Getting artwork files from: " << PIX::CachePath;

    //    if(!PIX::fileExists(notifyDir+"/Pix.notifyrc"))
    //    {
    //        qDebug()<<"The Knotify file does not exists, going to create it";
    //        QFile knotify(":Data/data/Pix.notifyrc");

    //        if(knotify.copy(notifyDir+"/Pix.notifyrc"))
    //            qDebug()<<"the knotify file got copied";
    //    }

    QDir collectionDBPath_dir(PIX::CollectionDBPath);
    QDir cachePath_dir(PIX::CachePath);

    if (!collectionDBPath_dir.exists())
        collectionDBPath_dir.mkpath(".");
    if (!cachePath_dir.exists())
        cachePath_dir.mkpath(".");


    this->con = new CollectionDB(this);
    this->fileLoader = new FileLoader;
    this->watcher = new QFileSystemWatcher(this);
    connect(this->watcher, &QFileSystemWatcher::directoryChanged, this, &Pix::handleDirectoryChanged);

    connect(this, &Pix::populate, this, &Pix::populateDB);

    connect(this->fileLoader, &FileLoader::finished,[this]()
    {
        this->collectionWatcher();
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

QVariantList Pix::get(const QString &queryTxt)
{
    return this->con->getDBDataQML(queryTxt);
}

bool Pix::run(const QString &query)
{
    return this->con->execQuery(query);
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

void Pix::collectionWatcher()
{
    auto queryTxt = QString("SELECT %1 FROM %2").arg(PIX::KEYMAP[PIX::KEY::URL], PIX::TABLEMAP[PIX::TABLE::IMAGES]);

    for (auto track : this->con->getDBData(queryTxt))
    {
        auto location = track[PIX::KEY::URL];

        if (!this->dirs.contains(QFileInfo(location).dir().path()) && PIX::fileExists(location)) //check if parent dir isn't already in list and it exists
        {
            QString dir = QFileInfo(location).dir().path();
            this->dirs << dir;

            QDirIterator it(dir, QDir::Dirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories); // get all the subdirectories to watch
            while (it.hasNext())
            {
                QString subDir = QFileInfo(it.next()).path();

                if(QFileInfo(subDir).isDir() && !this->dirs.contains(subDir) && PIX::fileExists(subDir))
                    this->dirs <<subDir;
            }
        }
    }

    this->addToWatcher(this->dirs);
}

void Pix::addToWatcher(QStringList paths)
{
    qDebug()<<"duplicated paths in watcher removd: "<<paths.removeDuplicates();

    if(!paths.isEmpty()) watcher->addPaths(paths);
}

void Pix::handleDirectoryChanged(const QString &dir)
{
    qDebug()<<"directory changed:"<<dir;

    auto wait = new QTimer(this);
    wait->setSingleShot(true);
    wait->setInterval(1000);

    connect(wait, &QTimer::timeout,[=]()
    {
        emit populate(dir);
        wait->deleteLater();
    });

    wait->start();
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


