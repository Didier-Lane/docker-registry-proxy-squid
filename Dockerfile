# https://hub.docker.com/r/docker/dockerfile
# syntax=docker/dockerfile:1.21

ARG DEBIAN_VERSION=13.4-slim
ARG DEBIAN_DIGEST=sha256:5fb70129351edec3723d13f427400ecae3f13b83750e23ad47c46721effcf2db

#
# base stage
#
FROM debian:${DEBIAN_VERSION}@${DEBIAN_DIGEST} AS base

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

ARG SQUID_VERSION=7_5
ARG SQUID_ARCHIVE=squid-7.5.tar.xz
ARG SQUID_ARCHIVE_DIGEST=sha256:f6058907db0150d2f5d228482b5a9e5678920cf368ae0ccbcecceb2ff4c35106
ARG SQUID_SIGNATURE=squid-7.5.tar.xz.asc
ARG SQUID_SIGNATURE_DIGEST=sha256:2637a60ea4e30e7573641d7b07fe8551f063aed08c274287e8fddc23aeda0b28

ENV SQUID_RELEASES=https://github.com/squid-cache/squid/releases
ENV SQUID_ARCHIVE_URL="${SQUID_RELEASES}/download/SQUID_${SQUID_VERSION}/${SQUID_ARCHIVE}"
ENV SQUID_ARCHIVE_DIGEST_HASH="${SQUID_ARCHIVE_DIGEST#*:}"
ENV SQUID_ARCHIVE_DIGEST_ALG="${SQUID_ARCHIVE_DIGEST%:*}"
ENV SQUID_SIGNATURE_URL="${SQUID_RELEASES}/download/SQUID_${SQUID_VERSION}/${SQUID_SIGNATURE}"
ENV SQUID_SIGNATURE_DIGEST_HASH="${SQUID_SIGNATURE_DIGEST#*:}"
ENV SQUID_SIGNATURE_DIGEST_ALG="${SQUID_SIGNATURE_DIGEST%:*}"

WORKDIR /tmp

# Install build dependencies
RUN <<EOR
	apk add --no-cache \
		curl \
		openssl-dev \
		build-base \
		automake \
		autoconf \
		libtool \
		libcap \
		gnupg
EOR

# Prepare Squid source
RUN <<EOR
	# get squid sources tarball
	curl -fSLO "$SQUID_ARCHIVE_URL"
	# checksum of sources digest
	# echo "f6058907db0150d2f5d228482b5a9e5678920cf368ae0ccbcecceb2ff4c35106" squid-7.5.tar.xz | "sha256sum" -c -
	echo "$SQUID_ARCHIVE_DIGEST_HASH" "$SQUID_ARCHIVE" | "${SQUID_ARCHIVE_DIGEST_ALG}sum" -c -
	# get signature for squid.tar.xz
	curl -fSLO "$SQUID_SIGNATURE_URL"
	# checksum of signature digest
	# echo "2637a60ea4e30e7573641d7b07fe8551f063aed08c274287e8fddc23aeda0b28" squid-7.5.tar.xz.asc | "sha256sum" -c -
	echo "${SQUID_SIGNATURE_DIGEST_HASH}" "$SQUID_SIGNATURE" | "${SQUID_SIGNATURE_DIGEST_ALG}sum" -c -
	# verify squid sources tarball with the gpg signature
	key="$( grep -Eo '^Key\s+:\s+([A-Z0-9]+)' $SQUID_SIGNATURE | sed 's/Key\s*:\s*//g' )"
	keyring="$( grep -Eo '^Keyring\s*:.*' $SQUID_SIGNATURE | sed 's/Keyring\s*:\s*//g' )"
	keyserver="$( grep -Eo '^Keyserver\s*:.*' $SQUID_SIGNATURE | sed 's/Keyserver\s*:\s*//g' )"
	echo "key=$key"
	echo "keyring=$keyring"
	echo "keyserver=$keyserver"
	gpg --status-fd 1 --keyring "$keyring" --keyserver "$keyserver" --recv-keys "$key"
	gpg --status-fd 1 --verify "$SQUID_SIGNATURE" "$SQUID_ARCHIVE"
	# extract the squid sources tarball
	tar xvf "$SQUID_ARCHIVE"
EOR

WORKDIR "/tmp/squid-${SQUID_VERSION/_/.}"

# Build Squid
RUN <<EOR
	MACHINE=$(uname -m)
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

HEALTHCHECK \
	--interval=30s --timeout=5s --retries=3 \
	--start-period=5s --start-interval=5s \
	CMD /bin/ash -Eeuo pipefail -c "test -f /var/run/squid/squid.pid"
