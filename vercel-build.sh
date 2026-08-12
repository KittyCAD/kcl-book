#!/bin/bash
set -euo pipefail

# This is a build script intended to be consumed by Vercel, though it should work locally if your platform matches.

# Toolchain versions live in one place, shared with CI and scripts/setup-local.sh.
# Resolved relative to this script so the build does not depend on the caller's cwd.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/versions.sh
. "$repo_root/scripts/versions.sh"

# First make sure Rust is available because we need to compile mdbook-kcl.
if [ -f /rust/env ]; then
  . /rust/env
fi
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

if ! command -v cargo >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . "$HOME/.cargo/env"
fi

if command -v rustup >/dev/null 2>&1; then
  rustup install stable
fi

# Make a temporary directory for binaries
mkdir -p bin

# Compile mdbook-kcl
cd mdbook-kcl
cargo build
cd -
mv mdbook-kcl/target/debug/mdbook-kcl bin
ls bin

# -f so an HTTP error fails the build loudly instead of writing an error page into
# the tarball and confusing tar; --retry to ride out transient GitHub blips.
curl -fL --retry 3 --retry-delay 2 -o mdbook-toc.tar.gz "https://github.com/badboy/mdbook-toc/releases/download/${MDBOOK_TOC_VERSION}/mdbook-toc-${MDBOOK_TOC_VERSION}-x86_64-unknown-linux-musl.tar.gz"
curl -fL --retry 3 --retry-delay 2 -o mdbook.tar.gz "https://github.com/rust-lang/mdBook/releases/download/v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-musl.tar.gz"
tar -xvzf mdbook.tar.gz -C bin
tar -xvzf mdbook-toc.tar.gz -C bin
export PATH="$(pwd)/bin:$PATH"
which mdbook-kcl
mdbook build kcl-book
node scripts/build-markdown-artifacts.mjs
