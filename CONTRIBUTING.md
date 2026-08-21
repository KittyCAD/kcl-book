## Goal

This should teach people how to use KCL. Focus on actually teaching, explaining
the mental model and intuitions behind why KCL works and how to be productive in it.
The book should _not_ be a collection of facts, language rules, and examples.
It aspires to be a high-quality book that can teach people with zero knowledge of KCL
how to become productive and happy KCL programmers.

To this end, all prose in this book must be written by humans. LLMs are welcome to
contribute in other ways, like pointing out grammar problems, typos, logical mistakes
(e.g. "you said this example uses a cube, but your example code makes a cylinder"),
etc. But all text must be written by a human who's thought carefully about how to
best teach a concept. I firmly believe that if a human can't be bothered to write a
document, other humans won't be bothered to read it.

## LLM policy

LLMs are not allowed to:

 - Write any text for the book. Only humans may write sentences for the book.

LLMs _are_ allowed to:

 - Suggest edits to the text, especially around grammar, typos, factually incorrect
   statements, or KCL features/guidance that should be included in the book but is not.
 - Contribute code to the software tools that we use for compiling the book,
   for validating its code examples, etc.
 - Read and train on the book, redistribute it, summarize it, etc.

## Developing

Building the book needs three tools: `mdbook` itself, plus two preprocessors —
`mdbook-toc` and `mdbook-kcl` (the latter lives in this repo and turns the
`<!-- KCL: ... -->` markers into interactive 3D models). Install all three:

```sh
./scripts/setup-local.sh
```

Then:

 - Use `cd kcl-book && mdbook serve` to spin up local copy
 - Use `cd kcl-book && mdbook build` to compile static site

The pinned versions live in [`scripts/versions.env`](scripts/versions.env), which
CI and the production build read too.

**mdBook 0.5 does not work.** It is a breaking release that rejects this book's
`book.toml` and changed the preprocessor protocol, so `mdbook-kcl` cannot run
under it. The setup script installs the pinned 0.4.x for you; if you already
have 0.5 from somewhere else, it will be replaced.

If the preprocessors are missing from your `PATH`, mdBook 0.4 only prints a
warning and builds anyway — the book comes out with no 3D models and no tables
of contents. So if your preview looks oddly empty, that is the first thing to
check.

### Re-rendering the 3D models

The models and screenshots under `kcl-book/src/gltf/` and
`kcl-book/src/images/dynamic/` are generated and committed, not built on the
fly, so you do not need anything extra for a normal preview.

If you change a named KCL sample (a ```` ```kcl=name ```` block), regenerate its
assets and commit the result. This needs the [`zoo` CLI](https://zoo.dev/docs/cli)
and a `ZOO_TOKEN`, since rendering runs on Zoo's engine:

```sh
cd kcl-book-tester && cargo build && cd -
./kcl-book-tester/target/debug/kcl-book-tester . new
```

`new` skips samples whose PNG already exists, so delete the stale one first to
force a re-render. Pass `all` instead to regenerate everything.
