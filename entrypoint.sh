#!/bin/sh
set -e
umask 002

if [ "$1" = 'dummy' ]; then
  exec gosu $UNAME bash -l -c 'cd $HOME/coast && scons -u --jobs=$(nproc) CoastRecipes --with-src-boost=3rdparty/boost --run'
fi
exec "$@"
