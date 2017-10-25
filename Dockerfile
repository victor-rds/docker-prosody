FROM ubuntu

ENV PROSODY_VERSION 0.10

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	lsb-base \
	adduser \
	libidn11 \
	libssl1.0.0 \
	lua-bitop \
	lua-dbi-mysql \
	lua-dbi-postgresql \
	lua-dbi-sqlite3 \
	lua-event \
	lua-expat \
	lua-filesystem \
	lua-sec \
	lua-socket \
	lua-zlib \
	lua5.1 \
	openssl \
	ca-certificates \
	ssl-cert \
	mercurial \
	&& DEBIAN_FRONTEND=noninteractive apt-get build-dep -y prosody
	

WORKDIR /usr/local/src/

RUN hg clone https://hg.prosody.im/trunk $PROSODY_VERSION \
	&& mv $PROSODY_VERSION prosody \
	&& cd prosody \
	&& ./configure --ostype=debian --prefix=/usr --sysconfdir=/etc/prosody --datadir=/var/lib/prosody \
	&& make \
	&& make install \
	&& make clean \
	&& cd .. \
	&& rm -rf prosody

RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge liblua5.1-dev libidn11-dev libssl-dev debhelper txt2man binutils build-essential bsdmainutils \
	&& DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y \
	&& rm -rf /var/lib/apt/lists/*
	
RUN sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
	&& perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua
	
VOLUME ["/etc/prosody", "/usr/lib/prosody/prosody-modules", "/var/log/prosody", "/var/lib/prosody/"]
	
EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["prosody"]