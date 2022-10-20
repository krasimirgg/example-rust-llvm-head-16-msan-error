# example-rust-llvm-head-16-msan-error

This is an example of an issue I encountered when building a sample rust binary with MemorySanitizer using a rust toolchain built with a recent LLVM at HEAD (16).
To reproduce, use `run_in_docker.sh`. That script: crates a Docker container, checks out rust and llvm at head in it, builds the stage1 rust toolchain and then uses it to build a sample binary with `-Zsanitize=memory`.
It's expected that this binary runs just fine. Instead if fails with an MSAN error:
```
Breakpoint 1 at 0x401e0: file /example/rust/src/llvm-project/compiler-rt/lib/msan/msan.cpp, line 394.
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
hi

Breakpoint 1, __msan_warning_noreturn () at /example/rust/src/llvm-project/compiler-rt/lib/msan/msan.cpp:394
394     void __msan_warning_noreturn() {
#0  __msan_warning_noreturn () at /example/rust/src/llvm-project/compiler-rt/lib/msan/msan.cpp:394
#1  0x00005642583215c4 in core::hint::black_box (dummy=()) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/core/src/hint.rs:226
#2  0x0000564258310e4b in std::sys_common::backtrace::__rust_begin_short_backtrace (f=0x5642583106b0 <foo::main>) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/sys_common/backtrace.rs:124
#3  0x00005642583109a9 in std::rt::lang_start::{{closure}} () at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/rt.rs:166
#4  0x00005642584225a5 in core::ops::function::impls::<impl core::ops::function::FnOnce<A> for &F>::call_once (self=..., args=()) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/core/src/ops/function.rs:286
#5  0x00005642585799da in std::panicking::try::do_call (data=0x7ffcb0931f80 "\310#\223\260\374\177") at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/panicking.rs:483
#6  0x00005642585844aa in __rust_try ()
#7  0x00005642585790b7 in std::panicking::try (f=...) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/panicking.rs:447
#8  0x0000564258419f9e in std::panic::catch_unwind (f=...) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/panic.rs:137
#9  0x00005642584d5b5f in std::rt::lang_start_internal::{{closure}} () at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/rt.rs:148
#10 0x0000564258579d0f in std::panicking::try::do_call (data=0x7ffcb09321b0 "\310#\223\260\374\177") at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/panicking.rs:483
#11 0x00005642585844aa in __rust_try ()
#12 0x0000564258578957 in std::panicking::try (f=...) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/panicking.rs:447
#13 0x000056425841a17e in std::panic::catch_unwind (f=...) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/panic.rs:137
#14 0x00005642584d55af in std::rt::lang_start_internal (main=..., argc=1, argv=0x7ffcb0932528, sigpipe=2) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/rt.rs:148
#15 0x00005642583108c6 in std::rt::lang_start (main=0x5642583106b0 <foo::main>, argc=1, argv=0x7ffcb0932528, sigpipe=2) at /example/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/src/rust/library/std/src/rt.rs:165
#16 0x000056425831077a in main ()
#17 0x00007f77d10ba083 in __libc_start_main (main=0x564258310720 <main>, argc=1, argv=0x7ffcb0932528, init=<optimized out>, fini=<optimized out>, rtld_fini=<optimized out>, stack_end=0x7ffcb0932518) at ../csu/libc-start.c:308
#18 0x00005642582a721e in _start ()
```

I checked that this works when using the initial llvm 16 revision, so something over at llvm changed to trigger this.
