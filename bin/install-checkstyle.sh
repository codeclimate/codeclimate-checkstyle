#!/bin/sh

# use `make upgrade` to update this URL to the latest version
URL='https://downloads.sourceforge.net/project/checkstyle/checkstyle/8.2/checkstyle-8.2-all.jar?r=&ts=1505330021&use_mirror=razaoinfo'

wget -O bin/checkstyle.jar $URL
