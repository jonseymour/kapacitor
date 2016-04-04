SHA1 := $(shell git rev-parse --short HEAD)

docker: binary
	mkdir -p build-products
	cp build/* build-products
	docker build -f Dockerfile_ninjasphere -t ninjasphere/kapacitor:$(SHA1) .
	echo built...ninjasphere/kapacitor:$(SHA1)

binary:
	godep restore
	KAPACITOR_USE_BUILD_CACHE=true ./build.sh
