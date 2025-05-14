# Installation

There are two main ways to work with KCL. You can use [Zoo Design Studio], our all-in-one application built specifically for KCL designs, or you can use a traditional programming interface with your own text editor. We definitely recommend the Zoo Design Studio.

## Zoo Design Studio

You can download [Zoo Design Studio], then open it and get started. There's a KCL code pane -- click the Code Editor button on the left edge of the screen. That's it! Get ready to design in KCL.

You'll note that when you write KCL code, the live 3D view updates, showing the model you've defined. And if you use the point-and-click buttons (to draw lines, or to select faces for extruding, or edges for filletting), the corresponding lines of code get highlighted. This two-way communication between the code and visuals is the key reason we think KCL will succeed where other code-CAD solutions failed. It's easy to tell exactly what part of the model your code corresponds to.

## Traditional code editing

You can download the [Zoo CLI], which lets you execute KCL programs and download some sort of visualization. You can download your KCL models as 3D files or as 2D images. Use `zoo kcl --help` to learn more.

You can edit KCL in whatever text editor you prefer. If you're using VSCode you can use our [VSCode extension]. For all other editors, our [LSP] is available. We hope to one day supply more developer tools, like a Treesitter grammar, but for now it's not a high priority. We'd happily work with anyone who'd like to contribute an open-source implementation though!

## Contributing to KCL

Our [GitHub] for Zoo Design Studio has all of our developer tooling and the language runtime. Please take a look there if you'd like to open any bugs or contribute to KCL! This book itself is [available on GitHub too]. Feel free to open issues or PRs.

[available on GitHub too]: https://github.com/KittyCAD/kcl-book
[GitHub]: https://github.com/KittyCAD/modeling-app
[LSP]: https://github.com/KittyCAD/modeling-app
[VSCode extension]: https://marketplace.visualstudio.com/items?itemName=KittyCAD.kcl-language-server
[Zoo CLI]: https://zoo.dev/docs/cli/manual
[Zoo Design Studio]: https://zoo.dev/modeling-app
