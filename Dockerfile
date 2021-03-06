FROM phusion/baseimage

ENV RUBY_MAJOR 2.1
ENV RUBY_VERSION 2.1.3

RUN apt-get update && apt-get install -y \
		autoconf \
		build-essential \
		imagemagick \
		libbz2-dev \
		libcurl4-openssl-dev \
		libevent-dev \
		libffi-dev \
		libglib2.0-dev \
		libjpeg-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libmysqlclient-dev \
		libncurses-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		zlib1g-dev \
		bzr \
		cvs \
		git \
		mercurial \
		subversion \
        curl procps && apt-get install -y nodejs --no-install-recommends 


# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get install -y bison ruby \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/ruby \
	&& curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
		| tar -xjC /usr/src/ruby --strip-components=1 \
	&& cd /usr/src/ruby \
	&& autoconf \
	&& ./configure --disable-install-doc \
	&& make -j"$(nproc)" \
	&& apt-get purge -y --auto-remove bison ruby \
	&& make install \
	&& rm -r /usr/src/ruby \
	&& rm -rf /var/lib/apt/lists/*

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

RUN gem install bundler

RUN mkdir -p /app
WORKDIR /app

ONBUILD ADD Gemfile /app/
ONBUILD ADD Gemfile.lock /app/
ONBUILD RUN bundle install --system

ONBUILD ADD . /app
CMD [ "irb" ]
