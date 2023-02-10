FROM ubuntu:22.04
LABEL maintainer="Brian Ketelsen"

ARG DEBIAN_FRONTEND=noninteractive
COPY sources.list /etc/apt/sources.list
# Install: dependencies, clean: apt cache, remove dir: cache, man, doc, change mod time of cache dir.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       software-properties-common \
       rsyslog systemd systemd-cron sudo gpg 
COPY os/etc/config/archives/vanilla.key /tmp/
RUN cat /tmp/vanilla.key | gpg --dearmor -o /usr/share/keyrings/vanilla-keyring.gpg

COPY os/etc/config/archives/vanilla.list /etc/apt/sources.list.d/
RUN apt-get update \
    && apt-get install -y \
    vanilla-base-meta \
    vanilla-base-desktop \
    switcheroo-control \
    epiphany-browser \
    gnome-calculator \
    gnome-music \
    gnome-photos \
    gnome-software \
    gnome-disk-utility \
    gnome-sushi \
    epiphany-browser \
    evince \
    yelp \
    file-roller \
    eog \
    orca \
    totem
RUN apt-get clean \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && rm -rf /var/lib/apt/lists/* \
    && touch -d "2 hours ago" /var/lib/apt/lists
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]

