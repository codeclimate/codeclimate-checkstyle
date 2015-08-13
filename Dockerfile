FROM java


MAINTAINER Sivakumar Kailasam 


# Groovy setup, defined multiple RUN steps for better caching resulting in
# quicker builds
RUN cd /tmp 
RUN wget http://dl.bintray.com/groovy/maven/groovy-binary-2.4.0-beta-4.zip 
RUN unzip groovy-binary-2.4.0-beta-4.zip 
RUN mv groovy-2.4.0-beta-4 groovy 
RUN rm groovy-binary-2.4.0-beta-4.zip

# Set Groovy path
ENV GROOVY_HOME /tmp/groovy
ENV PATH $GROOVY_HOME/bin/:$PATH

# Codeclimate specific setup
WORKDIR /code
COPY . /usr/src/app

#RUN adduser app -u 1212 --gid 9000
#USER app

VOLUME "/code"

CMD ["/usr/src/app/bin/checkstyle"]

