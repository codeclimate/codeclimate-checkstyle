#!/bin/sh

URL=$(curl -s https://api.github.com/repos/checkstyle/checkstyle/releases/latest | grep browser_download_url | cut -d\" -f4)
sed -i -E "s#URL=.*#URL='${URL}'#" bin/install-checkstyle.sh
echo $URL | sed -E 's/.*checkstyle-(.*)-all.jar/\1/' > CHECKSTYLE_VERSION
