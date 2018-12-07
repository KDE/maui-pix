#!/bin/bash

apt-get --yes update
apt-get --yes install wget gnupg2

### Add KDENeon Repository
echo 'deb http://archive.neon.kde.org/dev/stable/ bionic main' | tee /etc/apt/sources.list.d/neon-stable.list
wget -qO - 'http://archive.neon.kde.org/public.key' | apt-key add -

### Install Dependencies
apt-get --yes update
apt-get --yes dist-upgrade
wget http://repo.nxos.org/development/pool/main/m/mauikit/mauikit-dev_0%2Bgit20181114-1_amd64.deb 
dpkg -i mauikit-dev_0%2Bgit20181114-1_amd64.deb
wget http://repo.nxos.org/development/pool/main/m/mauikit/libmauikit_0%2Bgit20181114-1_amd64.deb
dpkg -i libmauikit_0%2Bgit20181114-1_amd64.deb
wget http://repo.nxos.org/development/pool/main/m/mauikit/qml-module-org-kde-mauikit_0%2Bgit20181114-1_amd64.deb
dpkg -i qml-module-org-kde-mauikit_0%2Bgit20181114-1_amd64.deb
apt-get --yes install devscripts lintian build-essential automake autotools-dev equivs qt5-default qtdeclarative5-dev qtquickcontrols2-5-dev qtwebengine5-dev cmake debhelper extra-cmake-modules libkf5config-dev libkf5coreaddons-dev libkf5i18n-dev libkf5kio-dev libkf5notifications-dev libkf5service-dev libqt5svg5-dev mauikit-dev qtbase5-dev qml-module-org-kde-mauikit
#apt-get --yes install devscripts lintian build-essential automake autotools-dev equivs qt5-default qtdeclarative5-dev qtquickcontrols2-5-dev qtwebengine5-dev cmake debhelper extra-cmake-modules libkf5config-dev libkf5coreaddons-dev libkf5i18n-dev libkf5kio-dev libkf5notifications-dev libkf5service-dev libqt5svg5-dev mauikit-dev qtbase5-dev qml-module-org-kde-mauikit
mk-build-deps -i -t "apt-get --yes" -r

### Build Deb
mkdir source
mv ./* source/ # Hack for debuild
cd source
debuild -b -uc -us
