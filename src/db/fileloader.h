#ifndef FILELOADER_H
#define FILELOADER_H

#include <QThread>
#include <QObject>
#include <QDirIterator>
#include <QFileInfo>
#include "dbactions.h"

class FileLoader : public DBActions
{
        Q_OBJECT

    public:
        FileLoader() : DBActions()
        {
            qRegisterMetaType<PIX::DB>("PIX::DB");
            qRegisterMetaType<PIX::TABLE>("PIX::TABLE");
            qRegisterMetaType<QMap<PIX::TABLE, bool>>("QMap<PIX::TABLE,bool>");
            this->moveToThread(&t);
            t.start();
        }

        ~FileLoader()
        {
            this->go = false;
            this->t.quit();
            this->t.wait();
        }

        void requestPath(QStringList paths)
        {
            qDebug()<<"FROM file loader"<< paths;
            this->queue << paths;
            for(auto url : this->queue)
            {
                if(!go)
                {
                    this->go = true;
                    QMetaObject::invokeMethod(this, "getPics", Q_ARG(QString, url));
                    this->queue.removeOne(url);
                }
            }
        }

        void nextTrack()
        {
            this->wait = !this->wait;
        }

    public slots:

        void getPics(QString path)
        {
            qDebug()<<"GETTING TRACKS FROM SETTINGS";

            QStringList urls;

            if (QFileInfo(path).isDir())
            {
                QDirIterator it(path, PIX::formats, QDir::Files, QDirIterator::Subdirectories);
                while (it.hasNext()) urls<<it.next();

            } else if (QFileInfo(path).isFile()) urls<<path;


            if(urls.size()>0)
            {
                int newTracks = 0;
                for(auto url : urls)
                {
                    if(go)
                    {
                        if(!this->checkExistance(PIX::TABLEMAP[PIX::TABLE::IMAGES], PIX::KEYMAP[PIX::KEY::URL],url))
                        {
                            QFileInfo info(url);
                            auto title = info.baseName();
                            auto format = info.suffix();
                            auto sourceUrl = info.dir().path();


                            PIX::DB trackMap =
                            {
                                {PIX::KEY::URL, url},
                                {PIX::KEY::TITLE, title},
                                {PIX::KEY::FAV, "0"},
                                {PIX::KEY::RATE, "0"},
                                {PIX::KEY::COLOR, ""},
                                {PIX::KEY::SOURCES_URL, sourceUrl},
                                {PIX::KEY::PIC_DATE, info.created().toString()}
                            };

                            this->addPic(trackMap);
                            newTracks++;

                        }
                    }else break;
                }

                emit collectionSize(newTracks);
            }

            this->t.msleep(100);
            emit this->finished();
            this->go = false;
        }

    signals:
        void trackReady(PIX::DB track);
        void finished();
        void collectionSize(int size);

    private:
        QThread t;
        bool go = false;
        bool wait = true;
        QStringList queue;
};


#endif // FILELOADER_H
