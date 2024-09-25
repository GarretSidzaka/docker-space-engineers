ARG TAG=latest


FROM debian:$TAG

#install non free repo for wine dependancies
RUN echo "deb http://deb.debian.org/debian $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) contrib non-free" > /etc/apt/sources.list.d/contrib.list

RUN     dpkg --add-architecture i386 \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        build-essential \
        iproute2 \
        vim \
        iputils-ping \
        fonts-wine \
        ttf-mscorefonts-installer \
        telnet \
        dpkg-dev \
        man-db \
        zstd \
        git \
        apt-transport-https \
        ca-certificates \
        cabextract \
        dbus-x11 \
        firefox-esr \
        git \
        gnupg \
        locales \
        btop \
        sudo \
        tzdata \
        unzip \
        wget \
        winbind \
        xvfb \
        zenity \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xorgxrdp \
        xrdp \
        steam-libs-i386 \
        steam-installer \
        steam-devices \
    && rm -rf /var/lib/apt/lists/*


# Install wine
ARG WINE_BRANCH="stable"
RUN wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && echo "deb https://dl.winehq.org/wine-builds/debian/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --install-recommends winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*

# Install winetricks
RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks
 
ENV WINEDEBUG=fixme-all
ENV WINEPREFIX=/debian/.wine
ENV WINEARCH=win64

RUN /usr/bin/winetricks -q win10
RUN sleep 1
RUN /usr/bin/winetricks -q dotnet48 
RUN sleep 1
RUN /usr/bin/winetricks -q corefonts 
COPY download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN chmod +x /root/download_gecko_and_mono.sh \
    && /root/download_gecko_and_mono.sh "$(wine --version | sed -E 's/^wine-//')"

# Configure locale and environment 
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

COPY entrypoint.sh /usr/bin/entrypoint
EXPOSE 3389/tcp
ENTRYPOINT ["/usr/bin/entrypoint"]
