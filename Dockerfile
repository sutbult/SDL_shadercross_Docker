# The releases and commits are up to date as of 2025-03-01.

# The statement --platform=linux/amd64 causes Docker to output a warning but
# trying to build for any other platform causes a failure on macOS (silicon)
# since libdxil.so and libdxcompiler.so is built for x86_64.
FROM --platform=linux/amd64 ubuntu:noble-20250127

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    cmake \
    curl \
    gcc \
    g++ \
    git \
    ninja-build

# Ninja has to be manually added to PATH.
ENV PATH="$PATH:/usr/lib/ninja-build/bin"

RUN mkdir /repos

WORKDIR /repos

# DirectXShaderCompiler

# DirectXShaderCompiler seems to be a partially closed source library.
# The prebuilt libraries are downloaded and installed manually by copying them
# to /usr/local as no other way of installing them is provided.

RUN mkdir /repos/dxc

WORKDIR /repos/dxc

RUN curl \
    -L -O \
    https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.8.2502/linux_dxc_2025_02_20.x86_64.tar.gz
RUN mkdir dxc_files
RUN tar -xvzf linux_dxc_2025_02_20.x86_64.tar.gz -C dxc_files
RUN mv -v dxc_files/lib/libdxil.so /usr/local/lib
RUN mv -v dxc_files/lib/libdxcompiler.so /usr/local/lib
RUN mv -v dxc_files/include/dxc /usr/local/include

WORKDIR /repos

RUN rm -rfv /repos/dxc

# SPIRV-Cross

RUN git clone \
    --no-checkout \
    https://github.com/KhronosGroup/SPIRV-Cross.git

WORKDIR /repos/SPIRV-Cross

RUN git checkout -q tags/vulkan-sdk-1.4.304.1

# Build SPIRV-Cross with shared libraries.
RUN cmake \
    -B build \
    -G Ninja \
    -DSPIRV_CROSS_SHARED=ON

RUN cmake --build build
RUN cmake --install build

WORKDIR /repos

RUN rm -rfv /repos/SPIRV-Cross

# SDL

RUN git clone \
    --no-checkout \
    https://github.com/libsdl-org/SDL.git

WORKDIR /repos/SDL

RUN git checkout -q tags/release-3.2.4

# Graphics is not needed.
RUN cmake \
    -B build \
    -G Ninja \
    -DSDL_UNIX_CONSOLE_BUILD=ON

RUN cmake --build build
RUN cmake --install build

WORKDIR /repos

RUN rm -rfv /repos/SDL

# SDL_shadercross

RUN git clone \
    --no-checkout \
    https://github.com/libsdl-org/SDL_shadercross.git

WORKDIR /repos/SDL_shadercross

RUN git checkout -q ba0ed2701477b6ae61f851f52875daf4cee141ca

# Enable installing.
RUN cmake \
    -B build \
    -G Ninja \
    -DSDLSHADERCROSS_INSTALL=ON

RUN cmake --build build
RUN cmake --install build

WORKDIR /

RUN rm -rfv /repos

# Required to find the dynamic libraries.
# See this: https://stackoverflow.com/a/13428971/6188897
RUN echo /usr/local/lib > "/etc/ld.so.conf.d/usr_local_lib.conf"
RUN ldconfig

# Start shadercross to ensure it can run.
RUN shadercross --help
