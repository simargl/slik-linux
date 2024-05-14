#!/bin/bash
# 
# Author: simargl <https://github.com/simargl>
# License: GPL v3

fn_create_sbo_packages() {
    cd /tmp
    for SLACKBUILD in "$@"; do \
        if [ ! -f "$(basename $SLACKBUILD)" ]; then
            wget $SLACKBUILD
            tar -xf "$(basename $SLACKBUILD)"
            i="$(basename $SLACKBUILD | sed s'/.tar.gz//'g)"
            cd $i; source $PWD/$i.info
            if [ ! -f "$(basename $DOWNLOAD)" ]; then
                wget $DOWNLOAD
            fi
            sh $i.SlackBuild
            cd -
            fetch it $PRGNAM-$VERSION-*
        fi
    done
}

fetch it $(fetch sr /d/|grep -v Installed|cut -d '(' -f1)
fn_create_sbo_packages "$@"

