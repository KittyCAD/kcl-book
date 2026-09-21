# Fillets, Chamfers and Edges

<!-- toc -->

## Motivation: Applying a fillet

When you manufacture a part, you often want to smooth off its sharp edges, so they're rounded and won't accidentally cut someone who holds it.
Let's say we're modeling a cube, like this:

```kcl=cube_no_fillets
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}

// Extrude a cube.
regionCube = region(segments = [square.line1, square.line2])
extrudeCube = extrude(regionCube, length = width)
```

It produces a cube like this:

<!-- KCL: name=cube_no_fillets,alt=A cube -->

What if we want to fillet one of its sides? Let's start simple and refer to one of the four bottom edges. Those edges were made by the four [`line`] function calls, which were all assigned to variables (`line1`, `line2`, etc). The region preserves those variables under `.tags`, so we can reference the edge created from `line1` via `regionCube.tags.line1` and apply a fillet to it.

```kcl=cube_one_fillet
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}

// Extrude a cube.
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(regionCube, length = width, tagStart = $startCap)

// Fillet one edge
filletCube = fillet(
  extrudeCube,
  edges = [{ sideFaces = [regionCube.tags.line1, startCap] }],
  radius = 0.2,
)
```

The [`fillet`] function accepts an `edges` array. Each edge reference describes the faces around an edge. Here, the edge is shared by the side face created from `line1` and the extrusion's `startCap`.

That program should produce a cube with one filleted edge, like this:

<!-- KCL: name=cube_one_fillet,alt=A cube with one filleted edge -->

Nice! We could fillet all four bottom sides if we wanted to:

```kcl=cube_four_fillets
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}

// Extrude a cube.
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(regionCube, length = width, tagStart = $startCap)

// Fillet all bottom edges
filletCube = fillet(
  extrudeCube,
  edges = [
    { sideFaces = [regionCube.tags.line1, startCap] },
    { sideFaces = [regionCube.tags.line2, startCap] },
    { sideFaces = [regionCube.tags.line3, startCap] },
    { sideFaces = [regionCube.tags.line4, startCap] },
  ],
  radius = 0.2,
)
```

<!-- KCL: name=cube_four_fillets,alt=A cube with four filleted edges-->

## Relationships between edges

The bottom and top edges of an extrusion share the same side face, but meet different caps. By tagging the start and end caps, we can describe both edges directly. See [Edge references] for a detailed explanation of `sideFaces`, `endFaces`, and `index`.


```kcl=cube_two_opposite_fillets
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// This is all the same as previous examples.
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(
  regionCube,
  length = width,
  tagStart = $startCap,
  tagEnd = $endCap,
)

filletCube = fillet(
  extrudeCube,
  edges = [
    // Fillet the bottom edge
    { sideFaces = [regionCube.tags.line1, startCap] },
    // Fillet the top edge
    { sideFaces = [regionCube.tags.line1, endCap] },
  ],
  radius = 0.2,
)
```

<!-- KCL: name=cube_two_opposite_fillets,alt=Cube with one filleted edge on the bottom and the opposite top edge too-->

We can use the same pattern to fillet all four bottom edges and all four top edges:

```kcl=cube_eight_fillets
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Same as previous examples:
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(
  regionCube,
  length = width,
  tagStart = $startCap,
  tagEnd = $endCap,
)

// Fillet edges
filletCube = fillet(
  extrudeCube,
  edges = [
    // Fillet the bottom four edges
    { sideFaces = [regionCube.tags.line1, startCap] },
    { sideFaces = [regionCube.tags.line2, startCap] },
    { sideFaces = [regionCube.tags.line3, startCap] },
    { sideFaces = [regionCube.tags.line4, startCap] },
    // Fillet the top four edges
    { sideFaces = [regionCube.tags.line1, endCap] },
    { sideFaces = [regionCube.tags.line2, endCap] },
    { sideFaces = [regionCube.tags.line3, endCap] },
    { sideFaces = [regionCube.tags.line4, endCap] },
  ],
  radius = 0.2,
)

```

<!-- KCL: name=cube_eight_fillets,alt=Cube with all top and bottom edge fillets-->

The vertical edges are shared by pairs of side faces:

```kcl=cube_next_prev_fillets
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}

// Extrude a cube
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(regionCube, length = width, tagStart = $startCap)

// Fillet edges
filletCube = fillet(
  extrudeCube,
  edges = [
    // Bottom edge
    { sideFaces = [regionCube.tags.line1, startCap] },
    // Two vertical edges at the ends of line1
    { sideFaces = [regionCube.tags.line1, regionCube.tags.line2] },
    { sideFaces = [regionCube.tags.line1, regionCube.tags.line4] },
  ],
  radius = 0.2,
)
```

<!-- KCL: name=cube_next_prev_fillets,alt=Cube with two side fillets and one bottom-->

Here, we filleted the bottom edge from `line1` and the two vertical edges at its endpoints. We can use adjacent pairs of side faces to fillet all four vertical edges:


```kcl=cube_next_prev_fillets_all_sides
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}

// Extrude a cube
regionCube = region(segments = [square.line1, square.line2])
extrudeCube = extrude(regionCube, length = width)

// Fillet edges
filletCube = fillet(
  extrudeCube,
  edges = [
    { sideFaces = [regionCube.tags.line1, regionCube.tags.line2] },
    { sideFaces = [regionCube.tags.line2, regionCube.tags.line3] },
    { sideFaces = [regionCube.tags.line3, regionCube.tags.line4] },
    { sideFaces = [regionCube.tags.line4, regionCube.tags.line1] },
  ],
  radius = 0.2,
)
```

<!-- KCL: name=cube_next_prev_fillets_all_sides,alt=Cube with two side fillets and one bottom fillet-->

## Edges between faces

Edge references describe this relationship directly: which faces does the edge touch?

```kcl=cube_common_edge
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// This is the same as previous examples
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}
regionCube = region(segments = [square.line1, square.line2])
extrudeCube = extrude(regionCube, length = width)

// Fillet the edge shared by the faces created from line1 and line2.
fillet(
  extrudeCube,
  edges = [{
    sideFaces = [regionCube.tags.line1, regionCube.tags.line2]
  }],
  radius = 0.2,
)
```

The `sideFaces` array contains the two faces shared by the edge. KCL recognizes that `extrude` creates a face from each sketch segment, so those faces are available through `regionCube.tags`.

There are other ways to refer to faces, but we'll see them later in this book.

## Chamfers

A [`chamfer`] is just like a fillet, except that fillets smooth away an edge to make it round, but chamfers just make a single cut across an edge. Here's an example of the difference. Compare this chamfered cube with the filleted cubes above:

```kcl=chamfered_cube
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Same as previous examples
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(regionCube, length = width, tagEnd = $endCap)

// Apply a chamfer
chamferedCube = chamfer(
  extrudeCube,
  edges = [{ sideFaces = [regionCube.tags.line1, endCap] }],
  length = 0.2,
)
```

<!-- KCL: name=chamfered_cube,alt=A chamfered cube-->

### Advanced chamfers

To define the chamfer, you only need to provide its `length`. But if you want more control of the chamfer angle, you can set the optional `secondLength` or `angle` parameters. Let's see how they work.

 Chamfering cuts away at two faces, creating a third face in between them. By default, the chamfer cuts away an even amount from both sides, creating a chamfered face at a 45 degree angle. The amount cut away from each face is the `length` parameter. But you can make a chamfer that cuts different amounts from each face, using the `secondLength` or `angle` parameters. This diagram shows the cross-section of a cube being chamfered:

![How chamfer lengths really work](images/static/advanced_chamfers.png)

Setting a second length which is much bigger or smaller than the first length means the chamfer will be "steep" -- the new face will be at a very sharp (or very obtuse) angle between the existing two faces. You can also set this angle explicitly, via the `angle` parameter. You can't use both `angle` and `secondLength` because they're essentially two different ways of setting the same property.

## Measuring geometry

So we've learned to use sketch variables and face relationships to reference geometry elsewhere in the model. These variables aren't just used for altering edges. They provide a valuable way to query and measure your models. Let's see how.

Let's say you've got a solid triangle, like this:

```kcl
// Make a triangle
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

sketch001 = sketch(on = YZ) {
  line1 = line(start = [var 5.29mm, var -4.11mm], end = [var -4.31mm, var -4.11mm])
  line2 = line(start = [var -4.31mm, var -4.11mm], end = [var 0.49mm, var 5.14mm])
  coincident([line1.end, line2.start])
  line3 = line(start = [var 0.49mm, var 5.14mm], end = [var 5.29mm, var -4.11mm])
  coincident([line2.end, line3.start])
  coincident([line3.end, line1.start])
  equalLength([line2, line3])
  horizontal(line1)
}

// Extrude it
region001 = region(segments = [sketch001.line1, sketch001.line2])
extrude001 = extrude(region001, length = 1)
```

Let's ask a simple question. How long is each side of the triangle?

It sounds simple, but to actually calculate it, you'd have to break out a pencil and paper, then do some trigonometry. The problem is, the length doesn't appear anywhere in the `line` function call. The lines are defined by their start and end points, and the length is an implicit property of those. Defining lines as a start and end is helpful, but it means important properties, like length, can't be read from our source code.

However, tags give us a simple way to refer to each line, and then query them for properties like length with the [`segLen`] function. Let's update our program:

```kcl
// Make a triangle
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

sketch001 = sketch(on = YZ) {
  line1 = line(start = [var 5.29mm, var -4.11mm], end = [var -4.31mm, var -4.11mm])
  line2 = line(start = [var -4.31mm, var -4.11mm], end = [var 0.49mm, var 5.14mm])
  coincident([line1.end, line2.start])
  line3 = line(start = [var 0.49mm, var 5.14mm], end = [var 5.29mm, var -4.11mm])
  coincident([line2.end, line3.start])
  coincident([line3.end, line1.start])
  equalLength([line2, line3])
  horizontal(line1)
}
// Extrude it
region001 = region(segments = [sketch001.line1, sketch001.line2])
extrude001 = extrude(region001, length = 1)

// Measure its side lengths
side1Len = segLen(extrude001.sketch.tags.line1)
side2Len = segLen(extrude001.sketch.tags.line2)
side3Len = segLen(extrude001.sketch.tags.line3)
```

Now you can open up the Variables pane and look at the `side1Len`, `side2Len` and `side3Len` variables to find each side's length. That's pretty useful! And if you want to use those lengths elsewhere in your code, you can! You could start drawing lines where the end is `[side1Len, 0]` for example, or plug those lengths into other calculations. 

There are other helpers too, like [`segStart`] and [`segEnd`] to find a line's start and end, respectively. Take a look at the KCL [standard library docs] to find them all.

[`chamfer`]: https://zoo.dev/docs/kcl-std/functions/std-solid-chamfer
[`fillet`]: https://zoo.dev/docs/kcl-std/functions/std-solid-fillet
[`segAng`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-segAng
[`segEnd`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-segEnd
[`segLen`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-segLen
[`segStart`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-segStart
[`line`]: https://zoo.dev/docs/kcl-std/functions/std-solver-line
[`extrude`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-extrude
[Edge references]: ./edge_references.md
[standard library docs]: <https://zoo.dev/docs/kcl-std>
