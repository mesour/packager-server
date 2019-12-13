#!/bin/bash
cd "$(dirname "$0")"

rm ../generated/packager-server.compressed

for source in $(find ../server/* -name '*' -type f); do
    echo "${source/..\/server\//} $(cat ${source} | base64)" >> ../generated/packager-server.compressed
done
