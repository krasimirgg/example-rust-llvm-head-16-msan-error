#!/bin/bash
set -eux

echo "Building rustc"

cd rust
python3 x.py build compiler
