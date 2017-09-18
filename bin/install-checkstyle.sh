#!/bin/sh

# use `make upgrade` to update this URL to the latest version
URL='https://downloads.sourceforge.net/project/checkstyle/checkstyle/8.2/checkstyle-8.2-all.jar'

wget -O /usr/local/bin/checkstyle.jar $URL
