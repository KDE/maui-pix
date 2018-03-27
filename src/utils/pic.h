#ifndef PIC_H
#define PIC_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QVariantList>

namespace PIX
{
    Q_NAMESPACE

    enum SearchT
    {
        LIKE,
        SIMILAR
    };

    typedef QMap<PIX::SearchT,QString> SEARCH;

    static const SEARCH SearchTMap
    {
        { PIX::SearchT::LIKE, "like" },
        { PIX::SearchT::SIMILAR, "similar" }
    };

    enum class W : uint_fast8_t
    {
        ALL,
        NONE,
        LIKE,
        TAG,
        SIMILAR,
        UNKNOWN,
        DONE,
        DESC,
        ASC
    };

    static const QMap<W,QString> SLANG =
    {
        {W::ALL, "ALL"},
        {W::NONE, "NONE"},
        {W::LIKE, "LIKE"},
        {W::SIMILAR, "SIMILAR"},
        {W::UNKNOWN, "UNKNOWN"},
        {W::DONE, "DONE"},
        {W::DESC, "DESC"},
        {W::ASC,"ASC"},
        {W::TAG,"TAG"}
    };

    enum class TABLE : uint8_t
    {
        SOURCES,
        IMAGES,
        TAGS,
        ALBUMS,
        IMAGES_TAGS,
        IMAGES_ALBUMS,
        ALL,
        NONE
    };

    static const QMap<TABLE,QString> TABLEMAP =
    {
        {TABLE::ALBUMS,"albums"},
        {TABLE::SOURCES,"sources"},
        {TABLE::IMAGES,"images"},
        {TABLE::IMAGES_TAGS,"images_tags"},
        {TABLE::IMAGES_ALBUMS,"images_albums"},
        {TABLE::TAGS,"tags"}
    };

    enum class KEY :uint8_t
    {
        URL,
        SOURCES_URL,
        TITLE,
        ALBUM,
        RATE,
        FAV,
        COLOR,
        NOTE,
        ADD_DATE,
        PIC_DATE,
        PLACE,
        FORMAT,
        TAG,
        NONE
    };

    typedef QMap<PIX::KEY, QString> DB;
    typedef QList<DB> DB_LIST;

    static const DB KEYMAP =
    {
        {KEY::URL, "url"},
        {KEY::SOURCES_URL, "sources_url"},
        {KEY::RATE, "rate"},
        {KEY::TITLE, "title"},
        {KEY::ALBUM, "album"},
        {KEY::FAV, "fav"},
        {KEY::COLOR, "color"},
        {KEY::NOTE, "note"},
        {KEY::ADD_DATE, "addDate"},
        {KEY::PIC_DATE, "picDate"},
        {KEY::PLACE, "place"},
        {KEY::FORMAT, "format"},
        {KEY::ADD_DATE, "addDate"},
        {KEY::TAG, "tag"}
    };

    enum class AlbumSizeHint : uint
    {
        BIG_ALBUM = 200,
        MEDIUM_ALBUM = 120,
        SMALL_ALBUM = 80
    };

    inline QString getNameFromLocation(const QString &str)
    {
        QString ret;
        int index = 0;

        for(int i = str.size() - 1; i >= 0; i--)
            if(str[i] == '/')
            {
                index = i + 1;
                i = -1;
            }

        for(; index < str.size(); index++)
            ret.push_back(str[index]);

        return ret;
    }

    const QString PicturesPath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    const QString DownloadsPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    const QString HomePath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    const QString SettingPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/pix/";
    const QString CollectionDBPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/pix/";
    const QString CachePath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/pix/";
    const QString NotifyDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    const QString App = "Pix";
    const QString version = "1.0";
    const QString DBName = "collection.db";

    const QStringList MoodColors = {"#F0FF01","#01FF5B","#3DAEFD","#B401FF","#E91E63"};

    const QStringList formats {"*.jpg","*.jpeg","*.png","*.bmp","*.gif"};

    inline QString ucfirst(const QString &str)/*uppercase first letter*/
    {
        if (str.isEmpty()) return "";

        QStringList tokens;
        QStringList result;
        QString output;

        if(str.contains(" "))
        {
            tokens = str.split(" ");

            for(auto str : tokens)
            {
                str = str.toLower();
                str[0] = str[0].toUpper();
                result<<str;
            }

            output = result.join(" ");
        }else output = str;

        return output.simplified();
    }

    inline bool fileExists(const QString &url)
    {
        QFileInfo path(url);
        if (path.exists()) return true;
        else return false;
    }

    inline void savePic(DB &track, const QByteArray &array, const QString &path)
    {
        if(!array.isNull()&&!array.isEmpty())
        {
            // qDebug()<<"tryna save array: "<< array;

            QImage img;
            img.loadFromData(array);
            QString name = track[PIX::KEY::TITLE];
            name.replace("/", "-");
            name.replace("&", "-");
            QString format = "JPEG";
            if (img.save(path + name + ".jpg", format.toLatin1(), 100))
                qDebug()<<"image saved!";
            else  qDebug() << "couldn't save artwork";
        }else qDebug()<<"array is empty";
    }

    inline void saveSettings(const QString &key, const QVariant &value, const QString &group)
    {
        QSettings setting("Babe","babe");
        setting.beginGroup(group);
        setting.setValue(key,value);
        setting.endGroup();
    }

    inline QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
    {
        QVariant variant;
        QSettings setting("Babe","babe");
        setting.beginGroup(group);
        variant = setting.value(key,defaultValue);
        setting.endGroup();

        return variant;
    }

    inline bool isMobile()
    {
#if defined(Q_OS_ANDROID)
        return true;
#elif defined(Q_OS_LINUX)
        return false;
#elif defined(Q_OS_WIN32)
        return false;
#elif defined(Q_OS_WIN64)
        return false;
#elif defined(Q_OS_MACOS)
        return false;
#elif defined(Q_OS_IOS)
        return true;
#elif defined(Q_OS_HAIKU)
        return false;
#endif
    }

}




#endif // PIC_H
