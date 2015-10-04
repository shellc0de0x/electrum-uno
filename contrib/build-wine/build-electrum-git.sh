#!/bin/bash

# You probably need to update only this link
ELECTRUM_GIT_URL=https://github.com/cryptapus/electrum-uno.git
BRANCH=master
NAME_ROOT=electrum-uno

# These settings probably don't need any change
export WINEPREFIX=/opt/wine-electrum
PYHOME=c:/python27
PYTHON="wine $PYHOME/python.exe -OO -B"

# Let's begin!
cd `dirname $0`
set -e

cd tmp

if [ -d "electrum-git" ]; then
    # GIT repository found, update it
    echo "Pull"

    cd electrum-git
    git pull
    cd ..

else
    # GIT repository not found, clone it
    echo "Clone"

    git clone -b $BRANCH $ELECTRUM_GIT_URL electrum-git
fi

cd electrum-git
COMMIT_HASH=`git rev-parse HEAD | awk '{ print substr($1, 0, 11) }'`
echo "Last commit: $COMMIT_HASH"
cd ..


rm -rf $WINEPREFIX/drive_c/electrum-uno
cp -r electrum-git $WINEPREFIX/drive_c/electrum-uno
cp electrum-git/LICENCE .

# Build Qt resources
wine $WINEPREFIX/drive_c/Python27/Lib/site-packages/PyQt4/pyrcc4.exe C:/electrum-uno/icons.qrc -o C:/electrum-uno/lib/icons_rc.py
wine $WINEPREFIX/drive_c/Python27/Lib/site-packages/PyQt4/pyrcc4.exe C:/electrum-uno/icons.qrc -o C:/electrum-uno/gui/qt/icons_rc.py

cd ..

rm -rf dist/

$PYTHON "C:/pyinstaller/pyinstaller.py" --noconfirm --ascii -w deterministic.spec

# For building NSIS installer, run:
wine "$WINEPREFIX/drive_c/Program Files/NSIS/makensis.exe" electrum.nsi

DATE=`date +"%Y%m%d"`
cd dist
mv electrum-uno.exe $NAME_ROOT-$DATE-$COMMIT_HASH.exe
mv electrum-uno $NAME_ROOT-$DATE-$COMMIT_HASH
mv electrum-uno-setup.exe $NAME_ROOT-$DATE-$COMMIT_HASH-setup.exe
zip -r $NAME_ROOT-$DATE-$COMMIT_HASH.zip $NAME_ROOT-$DATE-$COMMIT_HASH
