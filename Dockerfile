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
	


RUN cd /usr/local/src \
	&& hg clone https://hg.prosody.im/trunk $PROSODY_VERSION \
	&& mv $PROSODY_VERSION prosody

WORKDIR /usr/local/src/prosody

RUN ./configure --ostype=debian && make && make install

RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge liblua5.1-dev libidn11-dev libssl-dev debhelper txt2man binutils build-essential bsdmainutils \
	&& DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y \
	&& rm -rf /var/lib/apt/lists/*
	
RUN sed -i '1s/^/daemonize = false;\n/' /usr/local/etc/prosody/prosody.cfg.lua \
	&& perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /usr/local/etc/prosody/prosody.cfg.lua
	
VOLUME ["/usr/local/etc/prosody", "/usr/local/lib/prosody/prosody-modules", "/var/log/prosody", "$PROSODY_MODULES", "$CUSTOM_MODULES"]
	
EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["prosody"]