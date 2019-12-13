#!/bin/bash
cd "$(dirname "$0")"

output=../generated/packager.lua
rm ${output}
cat ../server/library/JsonDecoder.lua ../installation/Packager.lua >> ${output}
