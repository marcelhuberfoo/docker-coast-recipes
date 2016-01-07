FROM marcelhuberfoo/arch

MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>

USER root

RUN echo -e '[infinality-bundle]\nSigLevel=Never\nServer = http://bohoomil.com/repo/$arch\n[infinality-bundle-fonts]\nSigLevel=Never\nServer = http://bohoomil.com/repo/fonts' >> /etc/pacman.conf
RUN pacman -Syy && \
    printf "\\ny\\ny\\n" | pacman -S  multilib-devel && \
    printf "y\\ny\\n" | pacman -Scc
RUN pacman -S --noconfirm --quiet --noprogressbar --needed python2 git lib32-openssl gdb doxygen graphviz \
    fontconfig-infinality-ultimate ibfonts-meta-base && \
    printf "y\\ny\\n" | pacman -Scc
RUN rm -f /var/lib/pacman/sync/*.db

ADD entrypoint.sh /
ADD pip.conf /$UNAME/.pip/
ADD coast-project.pem /$UNAME/
RUN chown -R $UNAME:$GNAME /$UNAME/

USER $UNAME
ENV GIT_SSL_NO_VERIFY=true VENVDIR=/$UNAME/.venv27scons
RUN echo "[[ -d \"\$VENVDIR\" ]] && . $VENVDIR/bin/activate" >> $HOME/.bashrc

#RUN echo "" | openssl s_client -connect devpi.coast-project.org:443 2>/dev/null \
#| openssl x509 -text \
#| sed -e '/-----BEGIN/p' -e '1,/-----BEGIN/d' > $HOME/coast-project.pem

RUN cd $HOME && git clone --single-branch --branch master --depth 1 https://github.com/pypa/virtualenv.git
RUN python2 $HOME/virtualenv/virtualenv.py $VENVDIR
RUN cd $HOME && git clone --single-branch --branch master --depth 1 git://git.coast-project.org/coast.git
RUN cd $HOME/coast && \
    git clone --single-branch --branch master --depth 1 https://gerrit.coast-project.org/r/p/boost.git 3rdparty/boost &&\
    git clone --single-branch --branch master --depth 1 https://gerrit.coast-project.org/r/p/wdscripts.git && \
    git clone --single-branch --branch master --depth 1 https://gerrit.coast-project.org/r/p/recipes.git

RUN bash -l -c 'pip install -U -r $HOME/coast/requires.txt'

USER root

EXPOSE 51200 51201

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dummy"]

