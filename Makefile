SHA1 := $(shell git rev-parse --short HEAD)

docker: binary
	godep restore
	docker build -f Dockerfile_ninjasphere -t ninjasphere/kapacitor:$(SHA1) .
	echo built...ninjasphere/kapacitor:$(SHA1)

binary:
	KAPACITOR_USE_BUILD_CACHE=true ./build.sh
