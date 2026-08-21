# Modules

<!-- toc -->

So far, all the KCL examples we've seen have been fairly small. But as you start modeling larger projects, you'll find that your code no longer neatly fits into one file. Organizing your code into smaller _modules_ can really help. In this chapter, we'll explain how to break your code into smaller _modules_, which let you break your one big KCL file into several smaller ones. This can help your models render much faster, by executing different modules in parallel.

## Splitting code into modules

So far, all our KCL examples have been a single file -- `main.kcl`. That's the default name that Zoo Design Studio and other KCL tools (like our command-line interface) use. But what happens when `main.kcl` gets too big? 

Say we have a KCL file like this, which defines a cube function, a sphere function, and then models several cubes and spheres.

```kcl=cubes_and_spheres
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

fn cube() {
  sideLen = 10
  sketch001 = sketch(on = XY) {
    line1 = line(start = [var 0mm, var 0mm], end = [var 3.08mm, var 0mm])
    line2 = line(start = [var 3.08mm, var 0mm], end = [var 3.08mm, var -3.01mm])
    line3 = line(start = [var 3.08mm, var -3.01mm], end = [var 0mm, var -3.01mm])
    line4 = line(start = [var 0mm, var -3.01mm], end = [var 0mm, var 0mm])
    coincident([line1.end, line2.start])
    coincident([line2.end, line3.start])
    coincident([line3.end, line4.start])
    coincident([line4.end, line1.start])
    parallel([line2, line4])
    parallel([line3, line1])
    perpendicular([line1, line2])
    horizontal(line3)
    coincident([line1.start, ORIGIN])
    equalLength([line1, line2, line3, line4])
    fixed([line1.start, ORIGIN])
    distance([line1.start, line1.end]) == sideLen
  }
  hide(sketch001)
  return region(segments = [sketch001.line1, sketch001.line2])
    |> extrude(length = sideLen)
}

fn sphere() {
  sphereRadius = 2cm
  sketch001 = sketch(on = XY) {
    line1 = line(start = [var -9.84mm, var 0mm], end = [var 10.19mm, var 0mm])
    distance([line1.start, line1.end]) == sphereRadius
    horizontal([line1.start, ORIGIN])
    horizontal([line1.end, ORIGIN])
    arc1 = arc(start = [var -3.87mm, var 9.09mm], end = [var -9.76mm, var 1.56mm], center = [var 0mm, var 0mm])
    coincident([arc1.center, ORIGIN])
    coincident([arc1.end, line1.start])
    coincident([arc1.start, line1.end])
  }
  hidden001 = hide(sketch001)
  region001 = region(segments = [sketch001.line1, sketch001.arc1])
  return revolve(region001, angle = 360deg, axis = X)
}

// Draw ten spheres and ten cubes.
map(
  [1..10],
  f = fn(@i) { return cube() |> translate(x = i * 20) },
)

map(
  [1..10],
  f = fn(@i) { return sphere() |> translate(y = i * 20)},
)
```

<!-- KCL: name=cubes_and_spheres,alt=Several cubes and spheres-->

We can split this file into two separate files, `cubes.kcl` and `spheres.kcl`. We'll put the `sphere` function and the `map` that makes ten spheres into `spheres.kcl`. Then the `cube` function and the `map` that makes ten cubes into `cubes.kcl`.

To tell `main.kcl` to execute these two files, we use the `import` keyword with each file's filepath.

```kcl
import "cubes.kcl"
import "spheres.kcl"
```

If you open this file, you'll see the same image as before (10 spheres and 10 cubes). There's two advantages to the multi-file approach:

 1. Grouping related code into its own file can make it easier to read.
 2. In KCL, _each module executes in parallel_. This means the cubes and spheres will be drawn simultaneously, taking roughly half the time. Splitting big KCL files into smaller modules really speed up large projects.

Each of your `.kcl` files is a KCL module. Import paths are always relative to the file doing the importing, so any module can import the `.kcl` files sitting next to it in the same directory. Once your project grows big enough to need subdirectories, there are a few more rules to learn -- see [Organizing modules into directories](#organizing-modules-into-directories) below.

One other rule: `import` statements must be at the _top level_ of a file. They can't be nested inside a function definition or any other block. They don't have to be the first lines in the file, though -- this is fine:

```kcl
sideLen = 10
import "cubes.kcl"
```

Most people put their imports at the top anyway, because it makes it easy to see what a file depends on.

## Importing and exporting specific items

In the previous example, we just imported an entire file, causing KCL to run all its code. But what if I want to use values from one KCL file (perhaps a variable like `radius = 20in` or a function like `cube`) in another file? You can `export` and `import` specific variables between KCL modules. Let's see how.

Here's a simple example. Let's export some constants from one file (`car_constants.kcl`) and import them into another (`car_wheel.kcl`).

```kcl
// car_constants.kcl
export wheelDiameter = 15in
export wheelDepth = 4in
export axleLength = 2in
```

Here, we export 3 different variables from `car_constants.kcl`. Next, let's import and use some of them.

```kcl
// car_wheel.kcl
import wheelDepth, wheelDiameter from "car_constants.kcl"

makeWheel(diameter = wheelDiameter)
|> extrude(length = wheelDepth)
```

You can export any variable, not just simple numbers. For example, we could `export fn cube(sideLength)` from `cube.kcl`, and then import it in `main.kcl` and use it to draw several cubes. Alternatively, `cube.kcl` could export an _actual cube_, not just a function to create one. Here's an example showing both of these:

```kcl
// cube.kcl
fn cube(sideLength) {
  sketch001 = sketch(on = XY) {
    // Code omitted for brevity; same as previous cube examples
  }
  return region(segments = [sketch001.line1, sketch001.line2])
    |> extrude(length = sideLen)
}

export mySpecificCube = cube(sideLength = 20)
```

Now in `main.kcl` we can access `mySpecificCube`, and translate or rotate it. We can also use the `cube` function to make more cubes.

```kcl
// main.kcl
import mySpecificCube, cube from "cube.kcl"

mySpecificCube |> translate(x = 50) |> rotate(pitch = 40)
secondCube = cube(sideLength = 7)
```

![The imported specific cube and a second cube created from the imported `fn cube`](images/static/two_cubes_import.png)

## Default export

Here's a little time-saving feature for KCL exports. The last expression or variable declared in a KCL module is its _default export_. This means we could shorten our program

```kcl
export fn cube(sideLength) {
  // Code omitted for brevity.
  // Same as previous example.
}

// This is the last expression in the module, so it's the _default export_.
cube(sideLength = 20)
```

and use it in `main.kcl` like this:

```kcl
// main.kcl
import cube from "cube.kcl"
// Let's use the default export, and give it a name.
import "cube.kcl" as mySpecificCube

mySpecificCube |> translate(x = 50) |> rotate(pitch = 45)
secondCube = cube(sideLength = 7)
```

## Organizing modules into directories

Once a project has more than a handful of files, you'll want to group them into directories. Say we're modeling a car, and we've put everything to do with the wheels in its own directory:

```text
car/
├── main.kcl
├── chassis.kcl
├── constants.kcl
└── wheels/
    ├── main.kcl
    ├── tire.kcl
    └── rim.kcl
```

KCL has three rules about which of these files can import which.

**1. Any module can import its neighbors.** Import paths are relative to the file doing the importing, not to the top of your project. So `car/main.kcl` can import `chassis.kcl` and `constants.kcl`, and `wheels/main.kcl` can import `tire.kcl` and `rim.kcl`.

**2. From a directory, you can only import its `main.kcl`.** So `car/main.kcl` can do this:

```kcl
import "wheels/main.kcl"
```

but _not_ this:

```text
import "wheels/tire.kcl"
```

which fails to parse with:

> import path to a subdirectory must only refer to main.kcl.

Think of a directory's `main.kcl` as its front door. Everything inside the directory is private, and `main.kcl` decides what the rest of the project is allowed to see. This keeps directories self-contained: you can rearrange the files inside `wheels/` without breaking anything outside it. The rule applies at any depth -- if `wheels/` had a `hardware/` directory inside it, `car/main.kcl` could import `"wheels/hardware/main.kcl"`. It's only the _last_ part of the path that has to be `main.kcl`.

**3. You can never import from a parent directory.** An import path can't start with `..`, and it can't be an absolute path like `/Users/me/parts/bolt.kcl`. So `wheels/tire.kcl` cannot do this:

```text
import "../constants.kcl"
```

which fails to parse with:

> import path may not start with '..'. Cannot reference a parent module or anything outside the bounds of your project.

Modules can only ever reach sideways or downwards, which means a directory never depends on where it's been placed. If a nested module needs a value from higher up in the project, pass it in as a function parameter instead of importing it: have `tire.kcl` export a `fn tire(diameter)`, and let `car/main.kcl` supply the diameter from `constants.kcl`.

### Re-exporting through `main.kcl`

Rule 2 sounds restrictive, but it isn't, because a `main.kcl` can pass items through from its neighbors using `export import`. This lets a directory expose exactly what it wants, and nothing else.

```kcl
// wheels/main.kcl
// Let the rest of the project use `tireWidth`, but keep the rest of tire.kcl private.
export import tireWidth from "tire.kcl"

// Or re-export everything that rim.kcl exports.
export import * from "rim.kcl"
```

Now `car/main.kcl` can import those items straight from the `wheels` directory, without knowing which file inside it they came from:

```kcl
// car/main.kcl
import tireWidth, rimWidth from "wheels/main.kcl"
```

Anything `wheels/main.kcl` doesn't re-export stays invisible outside the directory, even if the file it lives in exports it. Note that `export` only works on the `import x from "..."` and `import * from "..."` forms -- writing `export import "tire.kcl"` won't re-export anything.

### Naming an imported directory

When you import a whole module without naming it, KCL derives a name from the path. For a directory import, that name is the _directory_ name, not `main`:

```kcl
// This makes the module available as `wheels`, not `main`.
import "wheels/main.kcl"

// Access its exported items with `::`
myTire = wheels::tire()
```

If the name KCL derives wouldn't be a valid KCL identifier -- because the file name contains a hyphen or a space, or starts with a digit or underscore -- you have to name it yourself with `as`:

```kcl
import "cube-inches.kcl" as cubeInches
```

Finally, imports can't be circular. If `a.kcl` imports `b.kcl`, then `b.kcl` can't import `a.kcl`, directly or through a chain of other modules.

For more details, you can read the [modules reference] in the KCL docs.

[modules reference]: https://zoo.dev/docs/kcl-lang/modules
