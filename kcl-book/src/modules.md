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

Each of your `.kcl` files is a KCL module. Files can be imported from the same directory. If you want to import from another directory, you can only import `main.kcl` from that directory. Import statements have to be at the top of a file -- they can't be nested within something like a function definition.

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

For more details, you can read the [modules reference] in the KCL docs.

[modules reference]: https://zoo.dev/docs/kcl-lang/modules
