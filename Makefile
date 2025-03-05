# Trick used to get the absolute path to this makefile. Retrieved from:
# https://www.systutorials.com/how-to-get-the-full-path-and-directory-of-a-makefile-itself/
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(abspath $(dir $(mkfile_path)))

# The platform is explicitly set to linux/amd64 for reasons specified in
# Dockerfile.

docker-build:
	docker build \
		--platform=linux/amd64 \
		-t shadercross \
		.

# Compiles an example shader.
docker-run-example: docker-build
	docker run \
		--platform=linux/amd64 \
		-v ${mkfile_dir}/in:/in \
		-v ${mkfile_dir}/out:/out \
		--rm \
		-t shadercross \
		bash -c " \
			shadercross /in/triangle.vert.hlsl -o /out/triangle.vert.spv && \
			shadercross /in/triangle.vert.hlsl -o /out/triangle.vert.msl && \
			shadercross /in/triangle.vert.hlsl -o /out/triangle.vert.dxil"
