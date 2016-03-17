#!/bin/bash
# Run the build utility via Docker

set -e

# Make sure our working dir is the dir of the script
DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
cd $DIR

x=0
for arg in "$@"; do
	let x=x+1
	if test "$arg" = "--use-cache"; then
		KAPACITOR_USE_BUILD_CACHE=defined
		set -- "${@:1:$(expr $x - 1)}" "${@:$(expr $x + 1):$#}"
		break
	fi
done

# Build new docker image
docker build -f Dockerfile_build_ubuntu64 -t influxdata/kapacitor-builder $DIR
if test -n "$KAPACITOR_USE_BUILD_CACHE"; then
	docker run --entrypoint=/bin/true --name kapacitor-builder-cache influxdata/kapacitor-builder 2>/dev/null || true
fi
echo "Running build.py"
# Run docker
docker run --rm \
    -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    ${KAPACITOR_USE_BUILD_CACHE:+--volumes-from kapacitor-builder-cache} \
    -v $DIR:/root/go/src/github.com/influxdata/kapacitor \
    influxdata/kapacitor-builder \
    "$@"
