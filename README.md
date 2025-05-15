Our guide to KCL. Read it [here](https://zoo.dev/docs/kcl-book/intro.html).

## Setup

Make sure `mdbook` and `mdbook-toc` is installed. If you have cargo:

```sh
cargo install mdbook
cargo install mdbook-toc
```

## Development:

This repo has two projects:

 - The book itself, under `kcl-book/`
 - The book's linter/tester, under `kcl-book-tester/`. It checks that KCL code blocks parse, and if the code blocks have a filename, it'll generate PNG and GLTF assets for them too.

Use `mdbook serve` to spin up local copy
Use `mdbook build` to compile static site
Use `cd kcl-book-tester; cargo build` to build the tester
Run the tester with `cargo run`. It takes two arguments:
 - The path to the kcl-book repo
 - A string, either "new" or "all", which tells it whether to run all the code blocks, or just to generate assets for new code blocks that don't have their assets yet.
