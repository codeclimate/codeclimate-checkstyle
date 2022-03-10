FROM ruby:2.6.3-alpine

ENV LANG C.UTF-8

MAINTAINER "Code Climate <hello@codeclimate.com>"

RUN adduser -u 9000 -D app

# based on https://github.com/docker-library/openjdk/blob/master/8-jre/alpine/Dockerfile
# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u252
ENV JAVA_ALPINE_VERSION 8.275.01-r0

RUN set -x \
	&& apk update && apk add --no-cache --update \
		openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY bin/install-checkstyle.sh /usr/src/app/bin/
RUN chown -R app:app /usr/src/app

RUN ./bin/install-checkstyle.sh
RUN apk add --update make g++ git curl && bundle install

VOLUME /code
WORKDIR /code
COPY . /usr/src/app
RUN chown -R app:app /usr/src/app

USER app

CMD ["/usr/src/app/bin/codeclimate-checkstyle"]
