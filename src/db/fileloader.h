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

            this->go = true;
            QMetaObject::invokeMethod(this, "getPics", Q_ARG(QStringList, paths));

        }

        void nextTrack()
        {
            this->wait = !this->wait;
        }

    public slots:

        void getPics(QStringList paths)
        {
            qDebug()<<"GETTING TRACKS FROM SETTINGS";

            QStringList urls;

            for(auto path : paths)
                if (QFileInfo(path).isDir())
                {
                    QDirIterator it(path, PIX::formats, QDir::Files, QDirIterator::Subdirectories);
                    while (it.hasNext()) urls<<it.next();

                } else if (QFileInfo(path).isFile()) urls<<path;

            int newPics = 0;
            if(urls.size()>0)
            {
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


                            PIX::DB picMap =
                            {
                                {PIX::KEY::URL, url},
                                {PIX::KEY::TITLE, title},
                                {PIX::KEY::FAV, "0"},
                                {PIX::KEY::RATE, "0"},
                                {PIX::KEY::COLOR, ""},
                                {PIX::KEY::SOURCES_URL, sourceUrl},
                                {PIX::KEY::PIC_DATE, info.created().toString()},
                                {PIX::KEY::FORMAT, format}
                            };

                            this->addPic(picMap);
                            newPics++;
                        }
                    }else break;
                }

                emit collectionSize(newPics);
            }

            this->t.msleep(100);
            emit this->finished(newPics);
            this->go = false;
        }

    signals:
        void trackReady(PIX::DB track);
        void finished(int size);
        void collectionSize(int size);

    private:
        QThread t;
        bool go = false;
        bool wait = true;
        QStringList queue;
};


#endif // FILELOADER_H
