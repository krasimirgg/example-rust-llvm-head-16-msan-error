#!/bin/bash
set -eux
LLVM_REF=$1

git config --global user.email "nobody@example.com"
git config --global user.email "Mister Nobody the Robot"

echo "Updating LLVM to: $LLVM_REF"

function apply_subtarget_info_fix {
  # https://github.com/rust-lang/llvm-project/commit/a8f170c5611585510033764926b0c40a6901d001
  # without this, pass wrapper doesn't build.
  SUBTARGET_INFO_REF=a8f170c5611585510033764926b0c40a6901d001
  git cherry-pick $SUBTARGET_INFO_REF
}

cd rust/src/llvm-project
if [ "$(git remote | grep llvm | wc -l)" -eq "0" ]; then
  git remote add llvm https://github.com/llvm/llvm-project
fi
git fetch llvm
git checkout $LLVM_REF
git checkout -b llvmrust
apply_subtarget_info_fix
git status
git log -5
