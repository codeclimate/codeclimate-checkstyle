#!/bin/sh

# use `make upgrade` to update this URL to the latest version
URL='https://github.com/checkstyle/checkstyle/releases/download/checkstyle-10.7.0/checkstyle-10.7.0-all.jar'


wget -O /usr/local/bin/checkstyle.jar $URL
