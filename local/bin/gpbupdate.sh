#!/bin/sh

alias gpbupdate='git-pbuilder update --override-config'

gpbupdate
ARCH=i386 gpbupdate
DIST=buster-backports gpbupdate
ARCH=i386 DIST=experimental gpbupdate
ARCH=i386 DIST=bullseye gpbupdate
ARCH=i386 DIST=buster-backports gpbupdate
ARCH=i386 DIST=stretch-backports gpbupdate
DIST=stretch-backports gpbupdate

sudo du -h --max-depth=1 /var/cache/pbuilder

# git-pbuilder create
# ARCH=i386 git-pbuilder create
# DIST=buster-backports git-pbuilder create
# ARCH=i386 DIST=bullseye git-pbuilder create
# #ARCH=i386 DIST=experimental git-pbuilder create
# ARCH=i386 DIST=buster-backports git-pbuilder create
# ARCH=i386 DIST=stretch-backports git-pbuilder create
