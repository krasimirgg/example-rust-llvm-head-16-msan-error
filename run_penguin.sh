#!/bin/bash
set -eux

rustup toolchain link stage1 /example/rust/build/x86_64-unknown-linux-gnu/stage1

rm -rf penguin
cargo new --lib penguin
cd penguin
cat <<EOF >src/lib.rs
#![feature(core_intrinsics)]
#[no_mangle]
extern "C" fn penguin() -> i64 {
    let dummy = ();
    core::intrinsics::black_box(dummy);
    0
}
EOF

rustup default stage1

RUSTFLAGS="-Zsanitizer=memory -Csave-temps --emit=llvm-ir -Ccodegen-units=1 -Cllvm-args=-print-before-all -Cllvm-args=-filter-print-funcs=penguin" \
cargo --color=never -Zbuild-std build --target=x86_64-unknown-linux-gnu || true
