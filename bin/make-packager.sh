#!/bin/bash
cd "$(dirname "$0")"

output=../generated/packager.lua
rm ${output}
cat ../server/library/JsonDecoder.lua ../packager/Packager.lua >> ${output}
