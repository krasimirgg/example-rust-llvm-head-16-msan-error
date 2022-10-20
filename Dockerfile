FROM ubuntu:focal


RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin
RUN apt-get install -y \
  cmake \
  ninja-build \
  tzdata \
  build-essential \
  curl \
  git \
  wget \
  rsync \
  python3 \
  gdb \
  lld
RUN apt-get update

ARG RUSTUP_TOOLCHAIN=stable
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup toolchain install $RUSTUP_TOOLCHAIN
RUN rustup component add rust-src

WORKDIR /example

ARG RUST_REF=master
RUN git clone https://github.com/rust-lang/rust || true
RUN (cd rust && git checkout $RUST_REF)
RUN (cd rust && git submodule update --init --recursive)

ARG LLVM_REF=llvm/main
ADD update_llvm_branch.sh /example
RUN /example/update_llvm_branch.sh $LLVM_REF

ADD config.toml /example/rust
ADD build_rustc.sh /example
RUN /example/build_rustc.sh

ADD run.sh /example

# RUN (cd rust && echo "[llvm]\ndownload-ci-llvm = true">config.toml)
# RUN (cd rust && python3 x.py build library/std compiler/rustc src/tools/cargo)
