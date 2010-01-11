#!/bin/bash
PASSPHRASE="${1}"

HOMEPATH=""
COMPONENT=""
ORIGIN=""
DISTS=""

writeLog()
{
    echo "`date`: $1"
}

makeRepo() 
{
    writeLog "Change dir to ${HOMEPATH}"
    cd ${HOMEPATH} 
    
    for dist in ${DISTS}
    do
        writeLog "Create dir ${HOMEPATH}/dists/${1}/${COMPONENT}/binary-${dist}/"
        mkdir -p ${HOMEPATH}/dists/${1}/${COMPONENT}/binary-${dist}/
        
        writeLog "Create Release file in ${HOMEPATH}/dists/${1}/${COMPONENT}/binary-${dist}/"
        echo "Archive: ${1}
Version: ${2}
Component:  ${COMPONENT}
Origin: ${ORIGIN}
Label: ${ORIGIN}
Architecture: ${dist}" > ${HOMEPATH}/dists/${1}/${COMPONENT}/binary-${dist}/Release
        
        writeLog "Create Packages dists/${1}/${COMPONENT}/binary-${dist}/Packages.gz"
        apt-ftparchive packages pool/*_${dist}.deb | gzip -9 > dists/${1}/${COMPONENT}/binary-${dist}/Packages.gz
        apt-ftparchive packages pool/*_${dist}.deb > dists/${1}/${COMPONENT}/binary-${dist}/Packages
    done
    
    writeLog "Change dir to ${HOMEPATH}/dists/${1}/"
    cd ${HOMEPATH}/dists/${1}/
    
    writeLog "Create Release file"
    echo  "Origin: ${ORIGIN}
Label: ${ORIGIN}
Suite: ${1}
Version: ${2}
Codename: ${1}
Architectures: ${DIST}
Component: ${COMPONENT}
Description: ${ORIGIN} ${1} ${2}" > Release

    apt-ftparchive release . >> Release
    rm -f Release.gpg
    gpg --passphrase ${PASSPHRASE} --output Release.gpg -ba Release
}

# Ubuntu stuff
HOMEPATH="/home/moserre/dev/rssowl-debian.git/repo/rssowl/ubuntu"
COMPONENT="main"
ORIGIN="Ubuntu"
DISTS="i386 amd64"

makeRepo "hardy" "8.04"
makeRepo "intrepid" "8.10"
makeRepo "jaunty" "9.04"
makeRepo "karmic" "9.10"
makeRepo "lucid" "10.04"

# Debian stuff
HOMEPATH="/home/moserre/dev/rssowl-debian.git/repo/rssowl/debian"
COMPONENT="main"
ORIGIN="Debian"
DISTS="i386 amd64"

makeRepo "lenny" "5.0"

exit 0
