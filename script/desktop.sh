#!/usr/bin/env bash
echo "---- START: desktop.sh -------"
set -eu
# set options:
#  -x : enable debug
#  -e : chain all commands  with &&-operator, one fails = script fails
#  -u : prints error if unassigned variable is used and exits with error

# Skip script if DESKTOP is not true
if [[ "${DESKTOP}" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
    export DEBIAN_FRONTEND=noninteractive
    SSH_USER=${SSH_USERNAME:-vagrant}

    tmp_path=/tmp/xWSL
    git clone https://github.com/DesktopECHO/xWSL.git ${tmp_path}

    ### install 
    sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 957D2708A03A4626
    sudo apt-add-repository "deb [arch=amd64] http://ppa.launchpad.net/oibaf/graphics-drivers/ubuntu $(lsb_release -cs) main"

    sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com EB563F93142986CE
    sudo apt-add-repository "deb [arch=amd64] http://ppa.launchpad.net/xubuntu-dev/staging/ubuntu  $(lsb_release -cs) main"

    # xrdp
    apt-get -y --no-install-recommends install \
        ${tmp_path}/deb/gksu_2.1.0_amd64.deb \
        ${tmp_path}/deb/libgksu2-0_2.1.0_amd64.deb \
        ${tmp_path}/deb/libgnome-keyring0_3.12.0-1+b2_amd64.deb \
        ${tmp_path}/deb/libgnome-keyring-common_3.12.0-1_all.deb \
        ${tmp_path}/deb/multiarch-support_2.27-3ubuntu1_amd64.deb \
        ${tmp_path}/deb/xrdp_0.9.15-1ubuntuwsl1_amd64.deb \
        ${tmp_path}/deb/xorgxrdp_0.2.15-1ubuntuwsl1_amd64.deb \
        ${tmp_path}/deb/plata-theme_0.9.9-0ubuntu1~focal1_all.deb \
        ${tmp_path}/deb/fonts-cascadia-code_2005.15-1_all.deb \
        ${tmp_path}/deb/libfdk-aac1_0.1.6-1_amd64.deb \
        x11-apps \
        x11-session-utils \
        x11-xserver-utils \
        dbus-x11 \
        libgtkd-3-0 \
        libphobos2-ldc-shared90 \
        libvte-2.91-0 libvte-2.91-common \
        libvted-3-0 \
        libdbus-glib-1-2 \
        xvfb \
        xbase-clients \
        dialog \
        distro-info-data \
        dumb-init \
        inetutils-syslogd \
        xdg-utils \
        avahi-daemon \
        libnss-mdns \
        binutils \
        unzip \
        zip \
        unar \
        samba-common-bin \
        base-files \
        ubuntu-release-upgrader-core \
        packagekit \
        packagekit-tools \
        lhasa \
        arj \
        unace \
        liblhasa0 \
        apt-config-icons apt-config-icons-hidpi apt-config-icons-large apt-config-icons-large-hidpi \
        python3-distupgrade \
        python3-psutil

    ssh-keygen -A
    adduser xrdp ssl-cert

    #confige xrdp
    sed -E -i 's/^#?security_layer=.*/security_layer=tls/g' /etc/xrdp/xrdp.ini
    sed -E -i 's/^#?require_credentials=.*/require_credentials=true/g' /etc/xrdp/xrdp.ini
    # create devices and reconfigure xrdp package to fix failing xrdp-sesman service (do not change the format of the here-doc!)
    cat << EOF >> /home/${SSH_USER}/.bashrc

[[ ! -d /dev/dri ]] && sudo mkdir -p /dev/dri
[[ ! -c /dev/dri/card0 ]] && sudo mknod -m 666 /dev/dri/card0 c 226 0
[[ ! -c /dev/dri/renderD128 ]] && sudo mknod -m 666 /dev/dri/renderD128 c 226 128
[[ ! -c /dev/fb0 ]] && sudo mknod -m 666 /dev/fb0 c 29 0
if [[ ! -e ~/.is_xrdp_reconfigured ]];then
    sudo systemctl enable xrdp
    sudo systemctl enable xrdp-sesman
    sudo dpkg-reconfigure xrdp
    touch ~/.is_xrdp_reconfigured
fi
EOF

    # xfce 4.16
    apt-get -y --no-install-recommends install  \
        xfwm4 \
        pulseaudio \
        xfce4 \
        xfce4-pulseaudio-plugin \
        xfce4-appfinder \
        xfce4-notifyd \
        xfce4-terminal \
        xfce4-whiskermenu-plugin \
        xfce4-taskmanager \
        xfce4-panel \
        xfce4-session \
        xfce4-settings \
        libxfce4ui-utils \
        libwebrtc-audio-processing1 \
        pavucontrol \
        thunar thunar-volman thunar-archive-plugin \
        xfdesktop4 \
        xfce4-screenshooter \
        libsmbclient \
        gigolo \
        gvfs-fuse gvfs-backends gvfs-bin \
        mousepad \
        evince \
        xarchiver \
        lhasa \
        lrzip \
        lzip \
        lzop \
        ncompress \
        zip unzip \
        dmz-cursor-theme \
        gconf-defaults-service \
        hardinfo \
        synaptic \
        compton compton-conf \
        libconfig9 \
        qt5-gtk2-platformtheme \
        libtumbler-1-0 tumbler tumbler-common tumbler-plugins-extra \
        at-spi2-core

    # configure xfce
    apt-get -y install xmlstarlet

    ## remove header comment from xml
    total_lines=$(cat /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml | wc -l)
    header_lines=5
    tail_lines=$(expr $total_lines - $header_lines)
    tail -n ${tail_lines} /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml > /tmp/xsettings.xml
    mv /tmp/xsettings.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
    ## change xfce settings 
    xmlstarlet edit --inplace --update '//property[@name="Net"]/property[@name="ThemeName"]/@value' --value "Plata-Noir-Compact" /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
    xmlstarlet edit --inplace --update '//property[@name="Net"]/property[@name="IconThemeName"]/@value' --value "ubuntu-mono-dark" /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
    ## remove bottom panel
    xmlstarlet edit --inplace --delete '//property[@name="panels"]/value[@value="2"]' /etc/xdg/xfce4/panel/default.xml
    xmlstarlet edit --inplace --delete '//property[@name="panels"]/property[@name="panel-2"]' /etc/xdg/xfce4/panel/default.xml

    # copy missing xrdp-pulseaudio-installer focal drivers
    cp -r ${tmp_path}/dist/var/lib/xrdp-pulseaudio-installer /var/lib/

    # add fix pulse audio to prevent kill
    cat << EOF >> /home/${SSH_USER}/.bashrc

mkdir -p /home/${SSH_USER}/.config/autostart/
cat << EOT >> /home/${SSH_USER}/.config/autostart/fix_pulseaudio.desktop
[Desktop Entry]
Type=Application
Name=Fix Pulseaudio
Comment=Fix pulseaudio
Exec=pulseaudio -k
GenericName=fix-pulseaudio
EOT
EOF

    # webkit2gtk
    apt install -y  \
        ${tmp_path}/webkit2gtk/*.deb \
        epiphany-browser \
        libgstreamer1.0-0 \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-doc \
        gstreamer1.0-tools \
        gstreamer1.0-x \
        gstreamer1.0-alsa \
        gstreamer1.0-gl \
        gstreamer1.0-gtk3 \
        gstreamer1.0-qt5 \
        gstreamer1.0-pulseaudio

    # needs to disabel to prevent systemd timeouts for the xrdp service
    systemctl disable xrdp
    systemctl disable xrdp-sesman

fi

echo "---- END: desktop.sh -------"

