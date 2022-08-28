.PHONY: build clean

build: outdir
	DOCKER_BUILDKIT=1 docker build --file Dockerfile --output out .

outdir:
	mkdir -p ./out

clean:
	@rm -rf ./out
