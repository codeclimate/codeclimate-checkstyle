#!/bin/sh

URL=$(curl -s -i https://sourceforge.net/projects/checkstyle/files/latest/download | grep Location | awk '{print $2}'| sed 's/\?.*$//')
sed -i -E "s#URL=.*#URL='${URL}'#" bin/install-checkstyle.sh

echo $URL
