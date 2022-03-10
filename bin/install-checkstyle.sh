#!/bin/sh

# use `make upgrade` to update this URL to the latest version
URL='https://github.com/checkstyle/checkstyle/releases/download/checkstyle-8.39/checkstyle-8.39-all.jar'


wget -O /usr/local/bin/checkstyle.jar $URL
