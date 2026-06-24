#!/bin/bash
set -xe

[ -d build ] || git clone https://gitlab.com/ubports/porting/community-ports/halium-generic-adaptation-build-tools.git build
exec ./build/build.sh "$@"
