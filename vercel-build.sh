#!/bin/bash

# This is a build script intended to be consumed by Vercel, though it should work locally if your platform matches.

# First install Rust because we need to compile mdbook-kcl
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -y
rustup install stable

# Make a temporary directory for binaries
mkdir -p bin

# Compile mdbook-kcl
cd mdbook-kcl
cargo build
cd -
mv mdbook-kcl/target/debug/mdbook-kcl bin

curl -Lo mdbook-toc.tar.gz https://github.com/badboy/mdbook-toc/releases/download/0.14.2/mdbook-toc-0.14.2-x86_64-unknown-linux-musl.tar.gz
curl -Lo mdbook.tar.gz https://github.com/rust-lang/mdBook/releases/download/v0.4.49/mdbook-v0.4.49-x86_64-unknown-linux-musl.tar.gz
tar -xvzf mdbook.tar.gz -C bin
tar -xvzf mdbook-toc.tar.gz -C bin
export PATH="$(pwd)/bin:$PATH"
mdbook build kcl-book
