import info
from Package.CMakePackageBase import *


class subinfo(info.infoclass):
    def setTargets(self):
        self.svnTargets['master'] = 'https://invent.kde.org/maui/pix.git'

        for ver in ['1.2.2']:
            self.targets[ver] = 'https://download.kde.org/stable/maui/pix/1.2.2/pix-%s.tar.xz' % ver
            self.archiveNames[ver] = 'pix-%s.tar.gz' % ver
            self.targetInstSrc[ver] = 'pix-%s' % ver

        self.description = "Organize, browse, and edit your images."
        self.defaultTarget = '1.2.2'

    def setDependencies(self):
        self.runtimeDependencies["virtual/base"] = None
        self.runtimeDependencies["libs/qt5/qtbase"] = None
        self.runtimeDependencies["kde/libraries/kquickimageeditor"] = None
        self.runtimeDependencies["kde/maui/mauikit-filebrowsing"] = None
        self.runtimeDependencies["kde/maui/mauikit-texteditor"] = None
        self.runtimeDependencies["kde/maui/mauikit-imagetools"] = None
        self.runtimeDependencies["kde/maui/mauikit"] = None


class Package(CMakePackageBase):
    def __init__(self, **args):
        CMakePackageBase.__init__(self)
