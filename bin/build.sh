#!/bin/bash
cd "$(dirname "$0")"

./make-installer.sh
./make-dev-installer.sh
./make-packager.sh
./make-server.sh