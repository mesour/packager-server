#!/bin/bash
cd "$(dirname "$0")"

output=../generated/packager-installer.lua
rm ${output}
cat ../installation/prepend.lua ../server/library/Utils.lua ../utils/base64.lua ../utils/FileComposer.lua ../installation/PackagerInstaller.lua >> ${output}
