#!/bin/bash
set -eux

ARG="${1:-default}"

DOCKER_IMAGE_NAME=rustllvm
RUSTUP_TOOLCHAIN=nightly
RUST_REF=master
LLVM_REF=main

docker build -t $DOCKER_IMAGE_NAME:latest \
  --build-arg RUSTUP_TOOLCHAIN=$RUSTUP_TOOLCHAIN \
  --build-arg RUST_REF=$RUST_REF \
  --build-arg LLVM_REF=$LLVM_REF .

if [[ $ARG == 'penguin' ]]; then
  docker run -it $DOCKER_IMAGE_NAME:latest ./run_penguin.sh
else
  docker run -it $DOCKER_IMAGE_NAME:latest ./run.sh
fi
