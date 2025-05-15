use mdbook::BookItem;
use mdbook::book::{Book, Chapter};
use mdbook::errors::Error;
use mdbook::preprocess::{Preprocessor, PreprocessorContext};
use pulldown_cmark::{Event, Parser, Tag, TagEnd};

/// KCL book's custom preprocessor.
pub struct Kcl;

impl Kcl {
    pub fn new() -> Kcl {
        Kcl
    }
}

impl Preprocessor for Kcl {
    fn name(&self) -> &str {
        "kcl"
    }

    fn run(&self, ctx: &PreprocessorContext, mut book: Book) -> Result<Book, Error> {
        // Check config
        if let Some(_nop_cfg) = ctx.config.get_preprocessor(self.name()) {
            // No config yet
        }

        // Process each chapter
        let mut errors = Vec::new();
        let mut count = 0;
        book.for_each_mut(|mut item| match &mut item {
            BookItem::Chapter(chapter) => {
                // At the start of each chapter, insert a <script> that loads the model-viewer library.
                chapter.content.insert_str(
                    0,
                    "<script type=\"module\" src=\"scripts/model-viewer.js\"></script>\n",
                );
                if let Err(e) = remove_emphasis(&mut count, chapter) {
                    errors.push(e);
                }
            }
            _other => {}
        });

        // After processing, handle any errors.
        if let Some(first_err) = errors.pop() {
            return Err(first_err);
        }
        eprintln!("Found {} 3D images", count);
        Ok(book)
    }

    fn supports_renderer(&self, renderer: &str) -> bool {
        renderer == "html"
    }
}

#[derive(Default, Debug)]
struct KclRenderFields {
    name: String,
    alt: String,
    skip_3d: bool,
}

fn remove_emphasis(kcl_comments_found: &mut usize, chapter: &mut Chapter) -> Result<String, Error> {
    let mut buf = String::with_capacity(chapter.content.len());

    let events = Parser::new(&chapter.content).flat_map(|e: Event<'_>| match e {
        Event::Html(a) if a.starts_with("<!-- KCL:") => {
            println!("Found KCL render");
            let s = a.strip_prefix("<!-- KCL: ");
            let Some(s) = s else {
                eprintln!("Malformed KCL test {a}");
                return vec![Event::Html(a)];
            };
            let s = s.strip_suffix(" -->").unwrap();

            *kcl_comments_found += 1;
            let mut kcl_render = KclRenderFields::default();
            for (k, v) in s.split(',').map(|kv| kv.split_once('=').unwrap()) {
                if k == "name" {
                    kcl_render.name = v.to_owned();
                }
                if k == "alt" {
                    kcl_render.alt = v.to_owned();
                }
                if k == "skip3d" {
                    kcl_render.skip_3d = v == "true";
                }
            }

            eprintln!("Found KCL render: {kcl_render:?}");
            let KclRenderFields { name, alt, skip_3d } = kcl_render;
            let out: Vec<Event> = if skip_3d {
                let mv = format!(
                    r#"<model-viewer
            alt="{alt}"
            src="gltf/{name}/output.gltf"
            ar
            environment-image="images/moon_1k.hdr"
            poster="images/{name}.png"
            shadow-intensity="1"
            auto-rotate
            camera-controls touch-action="pan-y">
            </model-viewer>"#
                );
                vec![Event::Html(mv.into())]
            } else {
                vec![
                    Event::Start(Tag::Paragraph),
                    Event::Start(Tag::Image {
                        link_type: pulldown_cmark::LinkType::Inline,
                        dest_url: format!("images/static/{name}.png").into(),
                        title: alt.clone().into(),
                        id: "".into(),
                    }),
                    Event::Text(alt.into()),
                    Event::End(TagEnd::Image),
                    Event::End(TagEnd::Paragraph),
                ]
            };
            out
        }
        other => vec![other],
    });

    Ok(pulldown_cmark_to_cmark::cmark(events, &mut buf).map(|_| buf)?)
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn nop_preprocessor_run() {
        let test_chapter = r##"<!-- KCL: name=pill_2d,skip3d=false,alt=Alt text description cannot contain commas -->"##;
        let input_json = format!(
            r##"[
                {{
                    "root": "/path/to/book",
                    "config": {{
                        "book": {{
                            "authors": ["AUTHOR"],
                            "language": "en",
                            "multilingual": false,
                            "src": "src",
                            "title": "TITLE"
                        }},
                        "preprocessor": {{
                            "nop": {{}}
                        }}
                    }},
                    "renderer": "html",
                    "mdbook_version": "0.4.21"
                }},
                {{
                    "sections": [
                        {{
                            "Chapter": {{
                                "name": "Chapter 1",
                                "content": "{}",
                                "number": [1],
                                "sub_items": [],
                                "path": "chapter_1.md",
                                "source_path": "chapter_1.md",
                                "parent_names": []
                            }}
                        }}
                    ],
                    "__non_exhaustive": null
                }}
            ]"##,
            test_chapter,
        );
        let input_json = input_json.as_bytes();

        let (ctx, book) = mdbook::preprocess::CmdPreprocessor::parse_input(input_json).unwrap();
        let input_book = book.clone().sections.remove(0);
        let result = Kcl::new().run(&ctx, book);
        assert!(result.is_ok());

        // The nop-preprocessor should not have made any changes to the book content.
        let actual_book = &result.unwrap().sections[0];
        println!("{actual_book:#?}");

        // assert_eq!(actual_book, &expected_book);
    }

    #[test]
    fn other() {
        let s = "![2D pill, before extruding](images/static/pill_2d.png)";
        Parser::new(s).for_each(|e| {
            println!("{e:?}");
        });
    }
}
