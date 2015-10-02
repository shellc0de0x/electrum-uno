#!/bin/bash

# You probably need to update only this link
ELECTRUM_GIT_URL=https://github.com/cryptapus/electrum-uno.git
BRANCH=master
NAME_ROOT=electrum-uno

# These settings probably don't need any change
export WINEPREFIX=/opt/wine-electrum
export SYSTEMROOT="C:\\"
PYHOME=c:/python27
PYTHON="wine $PYHOME/python.exe -OO -B"

# Let's begin!
cd `dirname $0`
set -e

cd tmp

if [ -d "electrum-uno" ]; then
    # GIT repository found, update it
    echo "Pull"

    cd electrum-uno
    git pull
    cd ..

else
    # GIT repository not found, clone it
    echo "Clone"

    git clone -b $BRANCH $ELECTRUM_GIT_URL
fi

cd electrum-uno
COMMIT_HASH=`git rev-parse HEAD | awk '{ print substr($1, 0, 11) }'`
echo "Last commit: $COMMIT_HASH"
cd ..


rm -rf $WINEPREFIX/drive_c/electrum-uno
cp -r electrum-uno $WINEPREFIX/drive_c/electrum-uno
cp electrum-uno/LICENCE .

# Build Qt resources
wine $WINEPREFIX/drive_c/Python27/Lib/site-packages/PyQt4/pyrcc4.exe C:/electrum-uno/icons.qrc -o C:/electrum-uno/lib/icons_rc.py

# Copy ZBar libraries to electrum
#cp "$WINEPREFIX/drive_c/Program Files (x86)/ZBar/bin/"*.dll "$WINEPREFIX/drive_c/electrum/"

cd electrum-uno
PYTHON="wine $PYHOME/python.exe -OO"
$PYTHON setup.py install
PYTHON="wine $PYHOME/python.exe -OO -B"

cd ../..

rm -rf dist/

# For building standalone compressed EXE, run:
$PYTHON "C:/pyinstaller/pyinstaller.py" --noconfirm --ascii -w --onefile "C:/electrum-uno/electrum"

# For building uncompressed directory of dependencies, run:
#$PYTHON "C:/pyinstaller/pyinstaller.py" -a -y deterministic.spec
$PYTHON "C:/pyinstaller/pyinstaller.py" --noconfirm --ascii -w deterministic.spec

# For building NSIS installer, run:
wine "$WINEPREFIX/drive_c/Program Files/NSIS/makensis.exe" electrum.nsi

DATE=`date +"%Y%m%d"`
cd dist
mv electrum-uno.exe $NAME_ROOT-$DATE-$COMMIT_HASH.exe
mv electrum-uno $NAME_ROOT-$DATE-$COMMIT_HASH
mv electrum-uno-setup.exe $NAME_ROOT-$DATE-$COMMIT_HASH-setup.exe
zip -r $NAME_ROOT-$DATE-$COMMIT_HASH.zip $NAME_ROOT-$DATE-$COMMIT_HASH
