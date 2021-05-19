# Pix
Image gallery manager for Nitrux

Pix is an image gallery manager made for Maui.
Pix is a convergent and multiplatform app that works under Android and GNU Linux distros.

<a href='https://flathub.org/apps/details/org.kde.pix'><img width='190px' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-i-en.png'/></a>

## Build

### Dependencies
#### Qt core deps:
QT += qml, quick, sql

#### KF5 deps:
QT += KService KNotifications KNotifications KI18n KIOCore KIOFileWidgets KIOWidgets KNTLM

#### Submodules
##### MauiKit:
https://github.com/maui-project/mauikit.git

### Compilation
After all the dependencies are met you can throw the following command lines to build Index and test it

git clone https://github.com/maui-project/pix --recursive
cd index && mkdir build && cd build
qmake .. 
make

A binary should be created and be ready to use.

## Contribute
If you like the Maui project or Index and would like to get involve ther are several ways you can join us.
- UI/UX design for desktop and mobile platforms
- Plasma, KIO and Baloo integration
- Deployment on other platforms like Mac OSX, IOS, Windows.. etc.
- Integration with exiv2 on Android and GNU Linux
- Work on sharing and syncing on local networks
And also whatever else you would like to see on a convergent image viewer/gallery.

You can get in touch with me by opening an issue or email me:
chiguitar@unal.edu.co

## Screenshots

![](https://github.com/milohr/pix/blob/master/screenshots/view1.png)

![](https://github.com/milohr/pix/blob/master/screenshots/view2.png)

![](https://github.com/milohr/pix/blob/master/screenshots/view3.png)

![](https://github.com/milohr/pix/blob/master/screenshots/view4.png)

