#include "utils.h"
#include "pix.h"
#include <QPalette>
#include <QWidget>
#include <QColor>

using namespace PIX;
Utils::Utils(QObject *parent) : QObject(parent)
{ }

QString Utils::backgroundColor()
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

QString Utils::foregroundColor()
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

QString Utils::hightlightColor()
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

QString Utils::midColor()
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

QString Utils::altColor()
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


