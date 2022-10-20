#!/bin/bash
set -eux

rustup toolchain link stage1 /example/rust/build/x86_64-unknown-linux-gnu/stage1

rm -rf foo
cargo new --lib foo
cd foo
cat <<EOF >src/main.rs
use std::mem::MaybeUninit;

fn f() {
    unsafe {
        let a = MaybeUninit::<[usize; 4]>::uninit();
        let a = a.assume_init();
        println!("{}", a[2]);
    }
}

fn main() {
   // f();
   println!("hi");
}
EOF

cargo run
RUSTFLAGS=-Zsanitizer=memory cargo +nightly -Zbuild-std run --target=x86_64-unknown-linux-gnu

rustup default stage1

cargo run
RUSTFLAGS=-Zsanitizer=memory cargo -Zbuild-std run --target=x86_64-unknown-linux-gnu || true

cat <<EOF >gdb_commands.txt
set pagination off
set disable-randomization off
set overload-resolution off
br __msan_warning
br __msan_warning_noreturn
run
bt
q
EOF

gdb -x gdb_commands.txt /example/foo/target/x86_64-unknown-linux-gnu/debug/foo
