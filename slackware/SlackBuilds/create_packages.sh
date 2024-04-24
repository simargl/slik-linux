#!/bin/bash
# 
# Author: simargl <https://github.com/simargl>
# License: GPL v3


fn_create_slik_packages() {
    for i in $(ls --hide=create_packages.sh); do
        cd $i; source $PWD/$i.info
        if [ ! -f "$(basename $DOWNLOAD)" ]; then
            wget $DOWNLOAD
        fi
        sh $i.SlackBuild && cd -
    done
}

fn_create_sbo_packages() {
cd /tmp
for SLACKBUILD in \
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
        sh $i.SlackBuild && cd -
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

#fn_create_slik_packages
#fn_create_sbo_packages
#fn_create_nwg_packages
