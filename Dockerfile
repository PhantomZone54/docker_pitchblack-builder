FROM ubuntu:bionic

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="PitchBlack Recovery Builder" \
      org.label-schema.description="Ubuntu Bionic Image For Building @PitchBlackRecoveryProject, Rebased From @yshalsager/cyanogenmod:latest" \
      org.label-schema.url="https://pitchblackrecoveryproject.github.io/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vendor="Rokib Hasan Sagar" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND=noninteractive

ENV \
    LANG=C.UTF-8 \
    JAVA_OPTS=" -Xmx3584m " \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk-amd64

RUN sed 's/main$/main universe/' /etc/apt/sources.list 1>/dev/null

RUN apt-get -q -y update \
    && apt-get -q -y install \
        wget curl wput git subversion mercurial build-essential squashfs-tools automake autoconf binutils \
        software-properties-common tree sshpass \
        android-sdk-platform-tools android-tools-adb android-tools-adbd android-tools-fastboot \
        openjdk-8-jdk openjdk-8-jre openjdk-8-jre-headless maven nodejs\
        file screen axel bison ccache clang cmake rsync flex gnupg gperf pngcrush schedtool bsdmainutils \
        python-dev python3-dev zip lzop zlib1g-dev xz-utils patchutils \
        gcc gcc-multilib g++ g++-multilib libxml2 libxml2-utils xsltproc expat \
        libncurses5-dev lib32ncurses5-dev libreadline-gplv2-dev lib32z1-dev libsdl1.2-dev libwxgtk3.0-dev \
    && apt-get -y clean \
    && dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot \
    && chmod u+s /usr/bin/screen \
    && chmod 755 /var/run/screen \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN mkdir -p /home/builder \
    && useradd --no-create-home builder \
    && rsync -a /etc/skel/ /home/builder/ \
    && chown -R builder:builder /home/builder

RUN mkdir -p /home/builder/bin \
    && curl https://github.com/akhilnarang/repo/raw/master/repo > /home/builder/bin/repo \
    && curl -s https://api.github.com/repos/tcnksm/ghr/releases/latest | grep "browser_download_url" | grep "amd64.tar.gz" | cut -d '"' -f 4 | wget -qi - \
    && tar -xzf ghr_*_amd64.tar.gz \
    && cp ghr_*_amd64/ghr /home/builder/bin/ \
    && rm -rf ghr_* \
    && chmod a+x /home/builder/bin/repo /home/builder/bin/ghr

RUN echo "export PATH=/home/builder/bin:$PATH" >> /etc/bash.bashrc \
    && echo "export USE_CCACHE=1" >> /etc/bash.bashrc \
    && echo "export CCACHE_COMPRESS=1" >> /etc/bash.bashrc \
    && echo "export CCACHE_COMPRESSLEVEL=8" >> /etc/bash.bashrc \
    && echo "export CCACHE_DIR=/srv/ccache" >> /etc/bash.bashrc

ENV DEBIAN_FRONTEND=teletype

WORKDIR /home/builder/pitchblack

VOLUME [/home/builder]
VOLUME [/srv/ccache]

RUN CCACHE_DIR=/srv/ccache ccache -M 5G
