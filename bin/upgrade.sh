#!/bin/sh

URL=$(curl -s -i https://sourceforge.net/projects/checkstyle/files/latest/download | grep Location | awk '{print $2}')
ESCAPED_URL=$(echo $URL | sed 's/\&/\\&/g')
sed -i -E "s#URL=.*#URL='${ESCAPED_URL}'#" bin/install-checkstyle.sh

echo $ESCAPED_URL
