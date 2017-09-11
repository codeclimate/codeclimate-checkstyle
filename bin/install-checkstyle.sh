#!/bin/sh

curl -s -i https://sourceforge.net/projects/checkstyle/files/latest/download | \
  grep Location | \
  awk '{print $2}' | \
  xargs wget -O bin/checkstyle.jar
