#!/bin/sh
set -e
umask 002

if [ "$1" = 'dummy' ]; then
  gosu $UNAME bash -li -c 'cd $HOME/coast && \
        scons -u --jobs=2 --with-src-boost=3rdparty/boost --ignore-missing --doxygen-only && \
        scons -u --jobs=2 CoastRecipes --with-src-boost=3rdparty/boost && \
	cd apps/CoastRecipes && ln -s ../../doc/Coast/html COASTDoc'
  # -> stop this server using: docker kill --signal=TERM container
  exec gosu $UNAME bash -li -c 'cd $HOME/coast && scons -u --jobs=2 CoastRecipes --with-src-boost=3rdparty/boost --run'
fi
exec "$@"
