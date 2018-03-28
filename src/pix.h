#ifndef PIX_H
#define PIX_H


#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QVariantList>
#include "db/dbactions.h"

using namespace std;


class FileLoader;

class Pix : public DBActions
{
        Q_OBJECT

    public:
        explicit Pix(QObject* parent = nullptr);
        ~Pix();

        Q_INVOKABLE void refreshCollection();

        Q_INVOKABLE QVariantList getList(const QStringList &urls);
        Q_INVOKABLE bool run(const QString &query);

        Q_INVOKABLE static QString pixColor();

        Q_INVOKABLE static int screenGeometry(QString &side);
        Q_INVOKABLE static int cursorPos(QString &axis);

        Q_INVOKABLE static QString homeDir();

        Q_INVOKABLE static QVariantList getDirs(const QString &pathUrl);
        Q_INVOKABLE static QVariantMap getParentDir(const QString &path);

        Q_INVOKABLE static QVariantList openWith(const QString &url);
        Q_INVOKABLE static void runApplication(const QString &exec, const QString &url);

    private:
        FileLoader *fileLoader;

        void populateDB(const QStringList &paths);

    signals:
        void refreshViews(QVariantMap tables);

};



#endif // PIX_H
