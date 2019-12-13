#!/bin/bash
cd "$(dirname "$0")"

output=../generated/packager-installer.lua
rm ${output}
cat ../installation/prepend.lua ../installation/utils/base64.lua ../installation/utils/FileComposer.lua ../installation/PackagerInstaller.lua >> ${output}
