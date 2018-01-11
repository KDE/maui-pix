#include "pix.h"
#include "../db/fileloader.h"
#include <QFileSystemWatcher>
#include <QTimer>

using namespace PIX;

Pix::Pix(QObject *parent) : QObject(parent)
{



    qDebug() << "Getting collectionDB info from: " << PIX::CollectionDBPath;
    qDebug() << "Getting settings info from: " << PIX::SettingPath;
    qDebug() << "Getting artwork files from: " << PIX::CachePath;

    //    if(!PIX::fileExists(notifyDir+"/Babe.notifyrc"))
    //    {
    //        qDebug()<<"The Knotify file does not exists, going to create it";
    //        QFile knotify(":Data/data/Babe.notifyrc");

    //        if(knotify.copy(notifyDir+"/Babe.notifyrc"))
    //            qDebug()<<"the knotify file got copied";
    //    }

    QDir collectionDBPath_dir(PIX::CollectionDBPath);
    QDir cachePath_dir(PIX::CachePath);

    if (!collectionDBPath_dir.exists())
        collectionDBPath_dir.mkpath(".");
    if (!cachePath_dir.exists())
        cachePath_dir.mkpath(".");


    this->con = new CollectionDB("Pix", this);
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
    QVariantList res;
    for(auto data : this->con->getDBData(queryTxt))
    {
        QVariantMap map;
        for(auto key : data.keys())
            map[PIX::KEYMAP[key]] = data[key];

        res << map;
    }
    return res;
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

