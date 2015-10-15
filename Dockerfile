FROM marcelhuberfoo/arch

MAINTAINER Marcel Huber <marcelhuberfoo@gmail.com>

USER root

RUN sed -r -i -e ':a;N;$!ba' -e 's|#(\[multilib\]\n)#([^\n]*\n)|\1\2|' /etc/pacman.conf
RUN echo -e '[infinality-bundle]\nServer = http://bohoomil.com/repo/$arch\n[infinality-bundle-fonts]\nServer = http://bohoomil.com/repo/fonts' >> /etc/pacman.conf
RUN pacman-key --recv-keys 962DDE58 && pacman-key --lsign-key 962DDE58
RUN pacman -Syyu --noconfirm && \
    pacman-db-upgrade && \
    printf "\\ny\\ny\\n" | pacman -S  multilib-devel && \
    pacman -S --noconfirm python2 git lib32-openssl gdb doxygen graphviz \
    fontconfig-infinality-ultimate ibfonts-meta-base && \
    printf "y\\ny\\n" | pacman -Scc
RUN sed -ri -e '/infinality-bundle/,$ {d}' /etc/pacman.conf

ADD entrypoint.sh /
ADD pip.conf /home/docky/.pip/
ADD coast-project.pem /home/docky/
RUN chown -R $UID:$GID /home/docky/

USER $UNAME
ENV GIT_SSL_NO_VERIFY=true VENVDIR=/home/docky/.venv27scons
RUN echo "[[ -d \"$VENVDIR\" ]] && . $VENVDIR/bin/activate" >> $HOME/.bashrc
RUN echo "cd $HOME" >> $HOME/.bashrc

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

USER root
RUN gosu $UNAME bash -li -c 'cd $HOME/coast && pip install -U -r $HOME/coast/requires.txt'

EXPOSE 51200 51201

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dummy"]

