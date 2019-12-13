#!/bin/bash
cd "$(dirname "$0")"

rm ../generated/packager-server.compressed

for source in $(find ../server/* -name '*' -type f); do
    printf "${source/..\/server\//}\n$(cat ${source} | base64)\n" >> ../generated/packager-server.compressed
done
