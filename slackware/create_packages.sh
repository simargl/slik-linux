#!/bin/bash
# 
# Author: simargl <https://github.com/simargl>
# License: GPL v3

fn_create_sbo_packages() {
cd /tmp
for SLACKBUILD in \
    https://slackbuilds.org/slackbuilds/15.0/libraries/date.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/system/FontAwesome.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/libraries/fltk.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/development/geany.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/libraries/girara.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/libraries/gtk-layer-shell.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/libraries/jsoncpp.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/libraries/libslirp.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/development/luajit.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/multimedia/mpv.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/libraries/spdlog.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/network/transmission.tar.gz \
    https://slackbuilds.org/slackbuilds/15.0/office/zathura.tar.gz; do \
    if [ ! -f "$(basename $slackbuild)" ]; then
        wget $SLACKBUILD
        tar -xf "$(basename $SLACKBUILD)"
        i="$(basename $SLACKBUILD | sed s'/.tar.gz//'g)"
        cd $i; source $PWD/$i.info
        if [ ! -f "$(basename $DOWNLOAD)" ]; then
            wget $DOWNLOAD
        fi
        if [ -f mpv.SlackBuild ]; then 
            sed 's/manpage-build=enabled/manpage-build=disabled/g' -i mpv.SlackBuild
            sed 's/html-build=enabled/html-build=disabled/g' -i mpv.SlackBuild
        fi
        if [ -f gtk-layer-shell.SlackBuild ]; then 
            sed 's/docs=true/docs=false/g' -i gtk-layer-shell.SlackBuild
            sed 's|cp -a  $PKG/usr/share/gtk-doc|#cp -a  $PKG/usr/share/gtk-doc|g' -i gtk-layer-shell.SlackBuild
            sed 's|rm -r $PKG/usr/share/gtk-doc/|#rm -r $PKG/usr/share/gtk-doc/|g' -i gtk-layer-shell.SlackBuild
        fi
        sh $i.SlackBuild
        cd -
    fi
done
}

fn_create_nwg_packages() {
    cd /tmp
    if [ ! -d nwg-shell_slackbuilds ]; then
        git clone https://github.com/mac-a-r0ni/nwg-shell_slackbuilds --depth 1
    fi
    cd nwg-shell_slackbuilds
    sed s'/bash-completions=true/bash-completions=false/'g -i grim/grim.SlackBuild
    for i in gammastep grim libdisplay-info libliftoff scdoc seatd swaybg wlroots; do
        cd $i; source $PWD/$i.info
        if [ ! -f "$(basename $DOWNLOAD)" ]; then
            wget $DOWNLOAD
        fi
        sh $i.SlackBuild && cd -
    done
}

fn_create_slik_packages() {
    if [ ! -d /tmp/slik/ ]; then mkdir /tmp/slik/; fi
    for i in $(ls SlackBuilds); do
        cp -a SlackBuilds/$i /tmp/slik/
    done
    cd /tmp/slik/
    for i in $(ls); do
        cd $i; source $PWD/$i.info
        if [ ! -f "$(basename $DOWNLOAD)" ]; then
            wget $DOWNLOAD
        fi
        sh $i.SlackBuild
        cd -
    done
}

fn_create_sbo_packages
fn_create_nwg_packages
fn_create_slik_packages
