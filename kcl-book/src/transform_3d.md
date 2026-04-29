# Transforming 3D solids
<!-- toc -->

We've covered many different ways to create 3D solids from 2D sketches, but what can we do with our solids afterwards? In this chapter we'll cover how to combine them via union, intersection and subtraction. This is sometimes called _constructive solid geometry_. We'll also look at how to scale, rotate or translate them. But before we get to that, let's start with something a little fun:

## Colour

So far, all our models have used the standard shiny grey metal appearance. But you can customize this! Let's change the texture. We'll make two cubes: one cyan, one shiny metallic green.

```kcl=cube_textures
// Sketch 2 squares.
sketch001 = sketch(on = XY) {
  // Rectangle 1
  line1 = line(start = [var -2.21mm, var -5.39mm], end = [var 2.8mm, var -5.39mm])
  line2 = line(start = [var 2.8mm, var -5.39mm], end = [var 2.8mm, var -0.39mm])
  line3 = line(start = [var 2.8mm, var -0.39mm], end = [var -2.21mm, var -0.39mm])
  line4 = line(start = [var -2.21mm, var -0.39mm], end = [var -2.21mm, var -5.39mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
  // Rectangle 2
  line5 = line(start = [var -10.25mm, var 2.72mm], end = [var -4.81mm, var 2.72mm])
  line6 = line(start = [var -4.81mm, var 2.72mm], end = [var -4.81mm, var 8.16mm])
  line7 = line(start = [var -4.81mm, var 8.16mm], end = [var -10.25mm, var 8.16mm])
  line8 = line(start = [var -10.25mm, var 8.16mm], end = [var -10.25mm, var 2.72mm])
  coincident([line5.end, line6.start])
  coincident([line6.end, line7.start])
  coincident([line7.end, line8.start])
  coincident([line8.end, line5.start])
  parallel([line6, line8])
  parallel([line7, line5])
  perpendicular([line5, line6])
  horizontal(line7)

  // Make all sides the same length (i.e. make the rectangles square).
  distance([line1.start, line1.end]) == 5
  equalLength([
    line1,
    line2,
    line3,
    line4,
    line5,
    line6,
    line7
  ])
}

region001 = region(point = [0.295mm, -5.3875mm], sketch = sketch001)
cube1 = extrude(region001, length = 5)
  |> appearance(color = "#00ffbf")

region002 = region(point = [-7.5300003mm, 2.9425003mm], sketch = sketch001)
cube2 = extrude(region002, length = 5)
  |> appearance(color = "#147807", metalness = 90, roughness = 60)
```

<!-- KCL: name=cube_textures,alt=Two cubes with different textures-->

The [`appearance`] call takes in three arguments, each of which is optional. You can provide:

 - A `color` as a hexadecimal number like `#0044ff`. The first two digits represent red, the next two green, and the last two blue. You can use an [online color picker] to play with the format. If you open your KCL in Zoo Design Studio, you can use an interactive color picker right there in the code editor.
 - A `metalness` percentage, which is a number between 0 and 100.
 - A `roughness` percentage, which is a number between 0 and 100.

This is helpful for making your different solids stand out from each other. We'll be using the `appearance` call in our examples to help make it clear which KCL snippets correspond to which objects in the rendered images.

## Clone and translate

We can transform solids, keeping them _basically_ the same -- the same number of sides, edges, and faces -- but changing some of their other properties.

Firstly, we can [`translate`] them (shifting them around in their coordinate system). To demonstrate this, we'll use the [`clone`] function to create a second copy of a cube, then use [`translate`] to move it left, then [`appearance`] to give it a different color:

```kcl=translate_cubes
// Sketch a square
sketch001 = sketch(on = XY) {
  // Sketch a rectangle first.
  line1 = line(start = [var -2.21mm, var -5.39mm], end = [var 2.8mm, var -5.39mm])
  line2 = line(start = [var 2.8mm, var -5.39mm], end = [var 2.8mm, var -0.39mm])
  line3 = line(start = [var 2.8mm, var -0.39mm], end = [var -2.21mm, var -0.39mm])
  line4 = line(start = [var -2.21mm, var -0.39mm], end = [var -2.21mm, var -5.39mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)

  // Make all sides the same length (i.e. make the rectangles square).
  distance([line1.start, line1.end]) == 5
  equalLength([line1, line2, line3, line4])
}

// This cube has the default silvery appearance.
region001 = region(point = [0.295mm, -5.3875mm], sketch = sketch001)
silverCube = extrude(region001, length = 5)

// Clone it, move it left, then make it green.
greenCube = clone(silverCube)
  |> translate(x = -10)
  |> appearance(color = "#00ff00", metalness = 80, roughness = 30)
```

<!-- KCL: name=translate_cubes,alt=Two translated cubes-->

The [`translate`] call takes three arguments, `x`, `y` and `z`. Each of them is optional. If you provide one, it'll shift the solid along that axis. If you don't provide an axis, it'll remain unchanged.

## Scale

Next, we can [`scale`] them, making them bigger or smaller.

```kcl=scaled_cubes
// Sketch a square
sketch001 = sketch(on = XY) {
  // Sketch a rectangle first.
  line1 = line(start = [var -2.21mm, var -5.39mm], end = [var 2.8mm, var -5.39mm])
  line2 = line(start = [var 2.8mm, var -5.39mm], end = [var 2.8mm, var -0.39mm])
  line3 = line(start = [var 2.8mm, var -0.39mm], end = [var -2.21mm, var -0.39mm])
  line4 = line(start = [var -2.21mm, var -0.39mm], end = [var -2.21mm, var -5.39mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)

  // Make all sides the same length (i.e. make the rectangles square).
  distance([line1.start, line1.end]) == 5
  equalLength([line1, line2, line3, line4])
}

// This cube has the default silvery appearance.
region001 = region(point = [0.295mm, -5.3875mm], sketch = sketch001)
silverCube = extrude(region001, length = 5)

// Clone it, move it up, make it 4x longer, and green.
greenCube = clone(silverCube)
  |> translate(z = 10)
  |> scale(y = 4)
  |> appearance(color = "#00ff00", metalness = 80, roughness = 30)
```

<!-- KCL: name=scaled_cubes,alt=Three scaled cubes-->

The [`scale`] call works similarly. You provide one or more axes -- if you don't provide an axis, it's left unchanged. Numbers less than 1 will shrink the solid (e.g. 0.25 means 1/4th its original size). Numbers larger than 1 will expand the solid (e.g. 4 means 4x its original size).

## Rotation

Lastly, we can rotate them. The [`rotate`] call is similar to translate and rotate: it takes a number of properties -- different ways to rotate -- all of which are optional, and if you don't provide one, it stays unchanged. These properties are roll, pitch and yaw.

**Roll**: Imagine spinning a pencil on its tip - that's a roll movement.
**Pitch**: Think of a seesaw motion, where the object tilts up or down along its side axis.
**Yaw**: Like turning your head left or right, this is a rotation around the vertical axis

Let's see an example:

```kcl=rotated_cubes
// Sketch a square
sketch001 = sketch(on = XY) {
  // Sketch a rectangle first.
  line1 = line(start = [var -2.21mm, var -5.39mm], end = [var 2.8mm, var -5.39mm])
  line2 = line(start = [var 2.8mm, var -5.39mm], end = [var 2.8mm, var -0.39mm])
  line3 = line(start = [var 2.8mm, var -0.39mm], end = [var -2.21mm, var -0.39mm])
  line4 = line(start = [var -2.21mm, var -0.39mm], end = [var -2.21mm, var -5.39mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)

  // Make all sides the same length (i.e. make the rectangles square).
  distance([line1.start, line1.end]) == 5
  equalLength([line1, line2, line3, line4])
}

// This cube has the default silvery appearance.
region001 = region(point = [0.295mm, -5.3875mm], sketch = sketch001)
silverCube = extrude(region001, length = 5)

extrude002 = clone(silverCube)
  |> translate(z = 10)
  |> rotate(roll = 45deg)
  |> appearance(color = "#00ff00", metalness = 80, roughness = 30)

extrude003 = clone(silverCube)
  |> translate(z = 20)
  |> rotate(pitch = 45deg)
  |> appearance(color = "#00ffe1", metalness = 80, roughness = 30)

extrude004 = clone(silverCube)
  |> translate(z = 30)
  |> rotate(yaw = 45deg)
  |> appearance(color = "#5900ff", metalness = 80, roughness = 30)
```

<!-- KCL: name=rotated_cubes,alt=Four rotated cubes-->

Note that these rotations are all around their own center (not the center of the plane).

Roll, pitch and yaw are one valid way to represent a rotation, but there are other ways too. You could also choose an axis, and rotate around that axis. For example, let's put 4 cubes at the same point, and then rotate them each a little bit around the axis.

```kcl=rotated_cubes_axis
// Sketch a square
sketch001 = sketch(on = XY) {
  // Sketch a rectangle first.
  line1 = line(start = [var -2.21mm, var -5.39mm], end = [var 2.8mm, var -5.39mm])
  line2 = line(start = [var 2.8mm, var -5.39mm], end = [var 2.8mm, var -0.39mm])
  line3 = line(start = [var 2.8mm, var -0.39mm], end = [var -2.21mm, var -0.39mm])
  line4 = line(start = [var -2.21mm, var -0.39mm], end = [var -2.21mm, var -5.39mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)

  // Make all sides the same length (i.e. make the rectangles square).
  distance([line1.start, line1.end]) == 5
  equalLength([line1, line2, line3, line4])
}

angle = 15deg

// This cube has the default silvery appearance.
region001 = region(point = [0.295mm, -5.3875mm], sketch = sketch001)
silverCube = extrude(region001, length = 1)

extrude002 = clone(silverCube)
  |> appearance(color = "#00ff00", metalness = 80, roughness = 30)
  |> rotate(axis = X, angle = angle)

extrude003 = clone(silverCube)
  |> appearance(color = "#00ffe1", metalness = 80, roughness = 30)
  |> rotate(axis = X, angle = angle * 2)

extrude004 = clone(silverCube)
  |> appearance(color = "#ffea00", metalness = 80, roughness = 60)
  |> rotate(axis = X, angle = angle * 3)
```

<!-- KCL: name=rotated_cubes_axis,alt=Four cubes rotated around the same axis-->

## Using transformations

You can combine multiple transformations, for example a translate and scale: `|> translate(x = 10) |> scale (y = 20)`. This can really simplify your mechanical engineering. For example, if you need to produce two cubes, rotated at different angles, which of these approaches sounds easier?

1. Make one cube with 4 sides, and then design the other cube from scratch using `line` calls that join the 4 rotated points
2. Make one cube, and then make a second cube by copying the first cube and adding a `rotation` call

These transformations make your job easier by letting you reuse work from previous designs. Once you know how to sketch a cube, you don't need to recalculate your cube every time it needs to grow, rotate or get moved over. You can just use our simple transformation functions. Recalculating a cube each time is annoying, but possible. For more complicated geometry, with weird curves and many edges, redoing all your calculations to handle different scales and rotations can be _very_ difficult and waste a lot of time! So don't recalculate them. Just reuse your work and transform it.

[`appearance`]: https://zoo.dev/docs/kcl-std/functions/std-solid-appearance
[`clone`]: https://zoo.dev/docs/kcl-std/functions/std-clone
[`translate`]: https://zoo.dev/docs/kcl-std/functions/std-transform-translate
[`scale`]: https://zoo.dev/docs/kcl-std/functions/std-transform-scale
[`rotate`]: https://zoo.dev/docs/kcl-std/functions/std-transform-rotate
[online color picker]: https://g.co/kgs/wVN95r4
