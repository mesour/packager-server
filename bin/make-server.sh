#!/bin/bash
cd "$(dirname "$0")"

output=../generated/packager-server.compressed
rm ${output}

for source in $(find ../server/* -name '*' -type f); do
    printf "${source/..\/server\//}\n$(cat ${source} | base64)\n" >> ${output}
done

echo "- packager-server.compressed is successfully created"