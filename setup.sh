#!/bin/bash

## Stop on any error.
set -e

## PLATFORM will be modified after executing get_platform platform
## It will be either osx, linux32 or linux64
PLATFORM=
## Depending on the PLATFORM, calling set_of_url will overwrite OF_RELEASE
OF_RELEASE=

get_platform () {
    ## 1. OS
    case $(uname -s) in
        Linux)
            case $(uname -m) in
                x86)    arch=32      ;;
                i?86)   arch=32      ;;
                ia64)   arch=64      ;;
                amd64)  arch=64      ;;
                x86_64) arch=64      ;;
                armv6l) arch=armv6l  ;;
                armv7l) arch=armv6l  ;;
                *)
                    echo "Non-32/64 architecture ... Really?!"
                    exit -1
                    ;;
            esac
            PLATFORM=linux$arch
            ;;
        Darwin)
            PLATFORM=osx
            ;;
        *)
            echo "Only supporting Linux or OS X"
            exit -1
            ;;
    esac
}

OF_PREFIX=https://openframeworks.cc/versions/v0.9.3
get_of () {
    case $PLATFORM in
        osx)
            OF_RELEASE=${OF_PREFIX}/of_v0.9.3_osx_release.zip
            curl $OF_RELEASE > third-party/of.zip
            unzip -q third-party/of.zip -d third-party
            ;;
        linux64)
            OF_RELEASE=${OF_PREFIX}/of_v0.9.3_linux64_release.tar.gz
            curl $OF_RELEASE > third-party/of.tar.gz
            tar -zxf third-party/of.tar.gz -C third-party
            ;;
        linux32)
            OF_RELEASE=${OF_PREFIX}/of_v0.9.3_linux32_release.tar.gz
            curl $OF_RELEASE > third-party/of.tar.gz
            tar -zxf third-party/of.tar.gz -C third-party
            ;;
        linuxarmv6l)
            OF_RELEASE=${OF_PREFIX}/of_v0.9.3_linuxarmv6l_release.tar.gz
            curl $OF_RELEASE > third-party/of.tar.gz
            tar -zxf third-party/of.tar.gz -C third-party
            ;;
    esac
}

get_platform

get_of

cd third-party
mkdir -p openFrameworks
( cd of_v0.9.3_$PLATFORM\_release && tar cf - . ) | (cd openFrameworks && tar xpf - )
rm -rf of_v0.9.3_$PLATFORM\_release/
cd ..

case $PLATFORM in
    osx)
        ## Remove files that depend on QuickTime.h, which isn't in Sierra.
        grep -vi 'ofQt' third-party/openFrameworks/libs/openFrameworksCompiled/project/osx/openFrameworksLib.xcodeproj/project.pbxproj > project.pbxproj
        mv project.pbxproj third-party/openFrameworks/libs/openFrameworksCompiled/project/osx/openFrameworksLib.xcodeproj/project.pbxproj
        ;;
esac

git submodule init
git submodule update

ln -s $(pwd)/third-party/ofxGrt/ third-party/openFrameworks/addons/ofxGrt
ln -s $(pwd)/third-party/ofxDatGui/ third-party/openFrameworks/addons/ofxDatGui
ln -s $(pwd)/third-party/ofxParagraph/ third-party/openFrameworks/addons/ofxParagraph

echo "Done"
