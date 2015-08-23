FROM java

MAINTAINER Sivakumar Kailasam 

# Groovy setup, defined multiple RUN steps for better caching resulting in quicker builds
RUN cd /tmp 
RUN wget http://dl.bintray.com/groovy/maven/groovy-binary-2.4.0-beta-4.zip 
RUN unzip groovy-binary-2.4.0-beta-4.zip 
RUN mv groovy-2.4.0-beta-4 /groovy 
RUN rm groovy-binary-2.4.0-beta-4.zip

# Set Groovy path
ENV GROOVY_HOME /groovy
ENV PATH $GROOVY_HOME/bin/:$PATH

# Install checkstyle
RUN wget http://downloads.sourceforge.net/project/checkstyle/checkstyle/6.9/checkstyle-6.9-all.jar
RUN mv checkstyle-6.9-all.jar bin/checkstyle.jar

# Codeclimate specific setup
WORKDIR /code
COPY . /usr/src/app

RUN useradd -r -s /bin/false app 
USER app

VOLUME "/code"

CMD ["/usr/src/app/bin/checkstyle.groovy", "--codeFolder=/code","--configFile=/config.json"]
