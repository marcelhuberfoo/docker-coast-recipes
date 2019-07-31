FROM instituteforsoftware/coast-build:latest

USER $USERNAME

RUN git clone --branch feature/FixCompilation https://gitlab.dev.ifs.hsr.ch/ifs/coast.git $SOURCEDIR/coast
WORKDIR $SOURCEDIR/coast 
RUN git clone --branch master https://gerrit.coast-project.org/p/boost.git 3rdparty/boost
RUN git clone --branch master https://gerrit.coast-project.org/p/openssl.git 3rdparty/openssl
RUN git clone --branch master https://gitlab.dev.ifs.hsr.ch/ifs/wdscripts.git
RUN git clone --branch master https://gerrit.coast-project.org/p/recipes.git

RUN bash -ic "pip install --upgrade -r $SOURCEDIR/coast/requires.txt"

ENV SCONSFLAGS="--enable-Trace --baseoutdir=$BUILDOUTPUTDIR/coast-build/ --with-src-boost=3rdparty/boost --with-bin-openssl=3rdparty/openssl"

RUN bash -ic "scons -u --jobs=$(nproc) CoastRecipes"
RUN bash -ic "scons -u --ignore-missing --doxygen-only && \
    ln -sf $BUILDOUTPUTDIR/coast-build/doc/Coast/html $BUILDOUTPUTDIR/coast-build/apps/CoastRecipes/COASTDoc"

EXPOSE 51200 51201
CMD bash -ic "scons -u --jobs=$(nproc) CoastRecipes --run-force"
