#!/usr/bin/env bash
set -euo pipefail

# Installs the toolchain needed to build the KCL book locally:
#
#   - mdbook       at the version pinned in scripts/versions.env
#   - mdbook-toc   likewise (renders the <!-- toc --> markers)
#   - mdbook-kcl   built from this repo (renders the <!-- KCL: ... --> markers
#                  into 3D <model-viewer> elements)
#
# Safe to re-run. mdbook and mdbook-toc are skipped if the pinned version is
# already installed; mdbook-kcl is always rebuilt, since it lives in this repo.

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/versions.env
. "$repo_root/scripts/versions.env"

if ! command -v cargo >/dev/null 2>&1; then
  echo "error: cargo not found. Install Rust from https://rustup.rs, then re-run." >&2
  exit 1
fi

# Prefers cargo-binstall, which downloads a prebuilt binary instead of
# compiling from source. Falls back to cargo install.
install_crate() {
  local crate="$1" version="$2"
  if command -v cargo-binstall >/dev/null 2>&1; then
    cargo binstall --no-confirm "${crate}@${version}"
  else
    cargo install "$crate" --version "$version" --locked
  fi
}

# Prints the semver a binary reports, or nothing if it is absent.
installed_version() {
  command -v "$1" >/dev/null 2>&1 || return 0
  "$1" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true
}

for spec in "mdbook:$MDBOOK_VERSION" "mdbook-toc:$MDBOOK_TOC_VERSION"; do
  bin="${spec%%:*}"
  want="${spec##*:}"
  have="$(installed_version "$bin")"
  if [ "$have" = "$want" ]; then
    echo "$bin $want already installed"
  else
    echo "installing $bin $want (found: ${have:-none})"
    install_crate "$bin" "$want"
  fi
done

echo "installing mdbook-kcl from $repo_root/mdbook-kcl"
cargo install --path "$repo_root/mdbook-kcl" --locked

echo
echo "Toolchain ready:"
for bin in mdbook mdbook-toc mdbook-kcl; do
  printf '  %-11s %s\n' "$bin" "$(command -v "$bin" || echo 'MISSING')"
done

cat <<'EOF'

Next:

  cd kcl-book && mdbook serve

If a preprocessor is missing from PATH, mdBook 0.4 only warns and carries on,
producing a book with no 3D models and no tables of contents. If the models are
missing from your local preview, check the three paths printed above.
EOF
