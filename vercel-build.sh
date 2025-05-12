curl -Lo mdbook-toc.tar.gz https://github.com/badboy/mdbook-toc/releases/download/0.14.2/mdbook-toc-0.14.2-x86_64-unknown-linux-musl.tar.gz
curl -Lo mdbook.tar.gz https://github.com/rust-lang/mdBook/releases/download/v0.4.49/mdbook-v0.4.49-x86_64-unknown-linux-musl.tar.gz
tar -xvzf mdbook.tar.gz
tar -xvzf mdbook-toc.tar.gz
export PATH="$(pwd)/mdbook-toc;$PATH"
./mdbook build kcl-book
