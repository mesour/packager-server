#!/bin/bash
cd "$(dirname "$0")"

output=../generated/packager-dev.lua
rm ${output}
cat ../installation/prepend.lua ../server/library/JsonDecoder.lua ../utils/GithubClient.lua ../installation/PackagerDevInstaller.lua >> ${output}
