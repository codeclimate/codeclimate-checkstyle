FROM ruby:2.3.0-slim

ENV LANG C.UTF-8

MAINTAINER Sivakumar Kailasam

RUN groupadd app -g 9000 && useradd -g 9000 -u 9000 -r -s /bin/false app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

WORKDIR /usr/src/app

RUN echo 'deb http://ftp.de.debian.org/debian jessie-backports main' >> /etc/apt/sources.list && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y build-essential git && \
    apt-get -y install -t jessie-backports openjdk-8-jdk ca-certificates-java && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
    bundle && \
    apt-get remove -y build-essential git

VOLUME /code
WORKDIR /code
COPY . /usr/src/app

USER app

CMD ["/usr/src/app/bin/codeclimate-checkstyle"]
