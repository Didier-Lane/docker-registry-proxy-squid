# https://hub.docker.com/r/docker/dockerfile
# syntax=docker/dockerfile:1.21

ARG ALPINE_VERSION="${ALPINE_VERSION:-3.23.3}"

#
# base stage
#
FROM alpine:${ALPINE_VERSION} AS base

SHELL ["/bin/ash", "-Eeuo", "pipefail", "-c"]

RUN <<EOR
	# Upgrade packages
	apk update
	apk upgrade
	# Install run deps
	apk add --no-cache \
		ca-certificates \
		openssl \
		libltdl \
		libstdc++ \
		libgcc \
		perl
	rm -rf /var/cache/apk/*
	# Create user squid
	addgroup squid
	adduser -S -D -h /var/cache/squid -G squid squid
	adduser squid tty
	mkdir -p /var/run/squid
	chown squid:squid -R /var/run/squid
EOR

#
# build stage
#
FROM base AS build

ARG SQUID_VERSION

WORKDIR /tmp

RUN <<EOR
	# Build deps
	apk add --no-cache \
		curl \
		openssl-dev \
		build-base \
		automake \
		autoconf \
		libtool \
		libcap
	# Prepare Squid source
	curl -fSLo squid.tar.gz "https://github.com/squid-cache/squid/archive/refs/tags/SQUID_${SQUID_VERSION}.tar.gz"
	tar xvzf squid.tar.gz
EOR


WORKDIR "/tmp/squid-SQUID_${SQUID_VERSION}"

# Build Squid
RUN <<EOR
	MACHINE=$(uname -m)
	autoreconf --install
	./configure \
		--build="$MACHINE" \
		--host="$MACHINE" \
		--bindir=/usr/local/bin \
		--sbindir=/usr/local/sbin \
		--libexecdir=/usr/local/bin \
		--sysconfdir=/etc/squid \
		--datarootdir=/usr/share \
		--with-default-user=squid \
		--with-swapdir=/var/cache/squid \
		--with-pidfile=/var/run/squid/squid.pid \
		--with-openssl \
		--with-large-files \
		--enable-ipv6 \
		--enable-ssl \
		--enable-ssl-crtd \
		--enable-arch-native \
		--enable-silent-rules \
		--disable-strict-error-checking \
		--disable-auto-locale \
		--disable-dependency-tracking \
		--disable-auth \
		--disable-icap-client \
		--disable-snmp \
		--disable-eui \
		--disable-htcp \
		--disable-select \
		--disable-poll \
		--disable-kqueue \
		--disable-epoll \
		--disable-devpoll \
		--without-psapi \
		--without-nettle \
		--without-gnutls \
		--without-mit-krb5 \
		--without-heimdal-krb5 \
		--without-gss \
		--without-ldap \
		--without-sasl \
		--without-systemd \
		--without-netfilter-conntrack \
		--without-tdb \
		--without-cppunit \
		CFLAGS="-g0 -O2" \
		CXXFLAGS="-g0 -O2" \
		LDFLAGS="-s"
	nproc=$(n=$(nproc) ; max_n=6 ; echo $(( n <= max_n ? n : max_n )) )
	make -j $nproc
	make install
EOR

#
# final stage
#
FROM base AS final

COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/sbin /usr/local/sbin
COPY --from=build /etc/squid /etc/squid
COPY --from=build /usr/share /usr/share

USER squid

VOLUME /var/cache/squid

EXPOSE 3128

COPY --chmod=0644 Dockerfile.d/etc /etc/squid

COPY --chmod=+x Dockerfile.d/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
