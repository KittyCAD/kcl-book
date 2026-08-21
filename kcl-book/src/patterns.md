# Patterns
<!-- toc -->

Real-world objects often have repeated parts. Consider a LEGO brick, which has a lot of repeated bumps on its top face. Or a table, with four repeated legs. KCL would be a very tedious language if we made you define each leg, or each LEGO bump, over and over again every time your model needed one. Luckily, there's a simple way to repeat geometry in your model. It's called a _pattern_. There are several ways to use patterns. Let's learn how they work!

## Basic patterns

Let's start simple. We can use patterns to replicate our geometry, copying it into our scene several times. Let's take this simple cylinder, and copy it 4 times.

```kcl=linear_pattern
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a circle
circleSketch = sketch(on = XY) {
  circle1 = circle(start = [var -1mm, var 1mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  distance([circle1.start, circle1.center]) == 2mm
}

// Extrude it into a cylinder, then pattern it.
cylinders = extrude(region(segments = [circleSketch.circle1]), length = 4)
  |> patternLinear3d(instances = 4, distance = 10, axis = X)
```

<!-- KCL: name=linear_pattern,alt=Using linear patterns to replicate a cylinder-->

The [`patternLinear3d`] function takes 4 args:
 - A solid to pattern (the unlabeled first arg, which is implicitly set to % and therefore gets the result of the `extrude()` call, i.e. the cylinder, piped in)
 - The total number of instances you want (i.e. how many total copies of the solid there should be)
 - How far apart each instance of the pattern should be
 - The axis along which to place the copies.

In our above example, it places 3 extra instances (for a total of 4) along the X axis, each 10 units apart.

**Note**: You can choose a standard axis like `X`, `Y` or `Z`, but you can also use any vector as an axis, like `[1, 1, 0.5]`.

## Circular patterns

You can also use patterns to replicate something and lay them out in an arc around a point. We'll use the [`patternCircular3d`] function. Here's an example where we put 12 cubes in a circle:

```kcl=circular_cubes_false
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square, just like normal.
sketch001 = sketch(on = XZ) {
  line1 = line(start = [var 2.66mm, var -2.08mm], end = [var -2.31mm, var -2.08mm])
  line2 = line(start = [var -2.31mm, var -2.08mm], end = [var -2.31mm, var 2.48mm])
  line3 = line(start = [var -2.31mm, var 2.48mm], end = [var 2.66mm, var 2.48mm])
  line4 = line(start = [var 2.66mm, var 2.48mm], end = [var 2.66mm, var -2.08mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
  equalLength([line1, line2, line3, line4])
  distance([line2.start, line2.end]) == 5mm
  coincident([line3.start, ORIGIN])
}

// Extrude square into a cube.
region001 = region(segments = [sketch001.line1, sketch001.line2])
cube = extrude(region001, length = 5)

// First, move the square to the northernmost position (like 12 o'clock)
translate(cube, z = 30)

// Then pattern the cube 12 times, around the origin.
  |> patternCircular3d(
       instances = 12,
       axis = Y,
       center = [0, 0, 0],
       arcDegrees = 360deg,
       rotateDuplicates = false,
     )
```

<!-- KCL: name=circular_cubes_false,alt=Using circular patterns to replicate a cube-->

Here, the center of the pattern is `[0, 0, 0]`. We drew the first cube at the northernmost position (12 o'clock) and all the other instances were patterned around that center. Nice!

**Note**: The `center` argument is optional, and defaults to `[0, 0, 0]`.

Notice that we used `rotateDuplicates = false`. If we set it to `true`, each duplicate object is also rotated as it is copied around the circle, so that they're all facing the center. Like this:

```kcl=circular_cubes_true
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square.
sketch001 = sketch(on = XZ) {
  line1 = line(start = [var 2.66mm, var -2.08mm], end = [var -2.31mm, var -2.08mm])
  line2 = line(start = [var -2.31mm, var -2.08mm], end = [var -2.31mm, var 2.48mm])
  line3 = line(start = [var -2.31mm, var 2.48mm], end = [var 2.66mm, var 2.48mm])
  line4 = line(start = [var 2.66mm, var 2.48mm], end = [var 2.66mm, var -2.08mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
  equalLength([line1, line2, line3, line4])
  distance([line2.start, line2.end]) == 5mm
  coincident([line3.start, ORIGIN])
}

// Extrude square into a cube.
region001 = region(segments = [sketch001.line1, sketch001.line2])
cube = extrude(region001, length = 5)

// First, move the square to the northernmost position (like 12 o'clock)
translate(cube, z = 30)
  // Then pattern the cube 12 times, around the origin.
  |> patternCircular3d(
       instances = 12,
       axis = Y,
       center = [0, 0, 0],
       arcDegrees = 360deg,
       rotateDuplicates = true,
     )
```

<!-- KCL: name=circular_cubes_true,alt=Using circular patterns to replicate a cube-->

The `arcDegrees` argument is optional, and defaults to 360 degrees. We can set it to `240deg` to only pattern around two thirds of the circle instead:

```kcl=circular_cubes_partway
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a square.
sketch001 = sketch(on = XZ) {
  line1 = line(start = [var 2.66mm, var -2.08mm], end = [var -2.31mm, var -2.08mm])
  line2 = line(start = [var -2.31mm, var -2.08mm], end = [var -2.31mm, var 2.48mm])
  line3 = line(start = [var -2.31mm, var 2.48mm], end = [var 2.66mm, var 2.48mm])
  line4 = line(start = [var 2.66mm, var 2.48mm], end = [var 2.66mm, var -2.08mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
  equalLength([line1, line2, line3, line4])
  distance([line2.start, line2.end]) == 5mm
  coincident([line3.start, ORIGIN])
}

// Extrude square into a cube.
region001 = region(segments = [sketch001.line1, sketch001.line2])
cube = extrude(region001, length = 5)

// First, move the square to the northernmost position (like 12 o'clock)
translate(cube, z = 30)
  // Then pattern the cube 12 times, around the origin.
  |> patternCircular3d(
       instances = 12,
       axis = Y,
       center = [0, 0, 0],
       arcDegrees = 240deg,
       rotateDuplicates = true,
     )
```

<!-- KCL: name=circular_cubes_partway,alt=Using semi-circular patterns to replicate a cube-->

You can use patterns and sketch on face together, patterning an extrusion upon some base.

```kcl=pattern_sof
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

// Sketch a big circle.
bigCircleSketch = sketch(on = XZ) {
  circle1 = circle(start = [var 0mm, var 10mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  vertical([circle1.center, circle1.start])
  distance([circle1.start, circle1.center]) == 10
}

// Extrude it into a "base".
bigCircle = region(segments = [bigCircleSketch.circle1])
base = extrude(bigCircle, length = 2)

// Start sketching a smaller circle on that base.
face001 = faceOf(base, face = END)
smallCircleSketch = sketch(on = face001) {
  circle1 = circle(start = [var -0.83mm, var 8.27mm], center = [var 0mm, var 7.79mm])
  vertical([circle1.center, ORIGIN])
  vertical([circle1.center, circle1.start])
}

// Extrude that circle into a small cylinder,
// then pattern it around.
region(segments = [smallCircleSketch.circle1])
  |> extrude(length = 2)
  |> patternCircular3d(
       instances = 6,
       axis = Y,
       useOriginal = true,
     )
```
<!-- KCL: name=pattern_sof,alt=Using a pattern to repeatedly sketch on face-->

**Note**: When patterning an extrusion which was originally sketched on a face, KCL doesn't know whether you want to pattern the entire modified solid (e.g. both the base solid and the volume added by sketch-on-face-then-extrude), or just the extrusion. By default, `useOriginal = false`, so the entire solid (original and new volume added via sketch-on-face-then-extrude) will be patterned. You can set `useOriginal = true` to only pattern the part added via sketch-on-face-then-extrude.

In other words, when `useOriginal = false` (the default), the total modified solid (made from a parent solid, and the modification) will be patterned around the global scene. When `useOriginal = true`, the modification will be patterned around the parent solid.

## Transform patterns

Circular and linear patterns cover a lot of really common use-cases for mechanical engineers. But sometimes you want to do more complicated patterns, in more complicated shapes. We can't add a dedicated pattern function for every single shape our users can think of -- that would be almost unmaintainable (there are infinite possible shapes, after all). Instead, KCL has a powerful, flexible interface for patterning solids in any arrangement you can think of. It's called a _transform_ pattern. They're created with the [`patternTransform`] function. It takes a familiar `instances` argument, which controls how many total copies of the shape you want. But it takes a new argument, called `transform`. This is a _custom function_. We'll dive deeper into those in the following chapters, but for now, they're basically just a way to calculate how to transform each replica in the pattern.

When might you need a pattern transform? Here's one use: to do a 2D pattern, like tiling a grid. Let's use a pattern transform to make a 5 by 5 grid.

```kcl=xform_grid
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

numColumns = 5    // how many columns in our grid
width = 10        // side length of each square
gap = 1.5 * width // gap between each square

// Sketch a square
squareSketch = sketch(on = XY) {
  line1 = line(start = [var -1.35mm, var 1.51mm], end = [var 1.44mm, var 1.51mm])
  line2 = line(start = [var 1.44mm, var 1.51mm], end = [var 1.44mm, var -1.25mm])
  line3 = line(start = [var 1.44mm, var -1.25mm], end = [var -1.35mm, var -1.25mm])
  line4 = line(start = [var -1.35mm, var -1.25mm], end = [var -1.35mm, var 1.51mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
  equalLength([line1, line2, line3, line4])
  distance([line4.start, line4.end]) == width
}

// Transform function.
// This takes in the instance number (called `i`), and returns a transform
// object that tells KCL how to transform that instance.
fn grid(@i) {
  column = rem(i, divisor = numColumns)
  row = floor(i / numColumns)
  // Return a KCL object, with one property, `translate`.
  // The `translate` property tells KCL how to translate each duplicated solid.
  return {
    translate = [column * gap, row * gap, 0]
  }
}

// Extrude square, then pattern it using the transform function.
region(segments = [squareSketch.line1, squareSketch.line2])
  |> extrude(length = 2)
  |> patternTransform(instances = numColumns * numColumns, transform = grid)
```

We've defined a _custom function_ called `grid`. This function will get called once for every replica in the pattern, and it tells KCL how each replica should be transformed. Specifically it:

 - Takes a single argument called `i`. It's used to indicate which number replica is currently being processed. The first copy made will set `i` to 1, the second copy will set `i` to 2, etc. The argument `i` is prefixed with `@` to indicate it's this function's special first unlabeled argument, so if you call it, you'd call it like `grid(1)` or `grid(2)`, not `grid(i = 1)`.
 - Returns a list of different properties to transform in each replica.

In this example, we define a function `grid` which tells `patternTransform` to translate each replica by a certain amount `column * gap` along the X axis, `row * gap` along the Y axis, and to stay on the same location on the Z axis (i.e. move exactly 0 along that axis).

The `grid` function is called by `patternTransform` as many times as `patternTransform`'s first argument, `instances`. On each call to `grid` the current instance number is passed and bound to `i`. In this example, because `numColumns` is `5` and the code uses `instances = numColumns * numColumns`, there will be `5 * 5 = 25` instances. So the pattern transform will call `grid(0)`, `grid(1)` ... `grid(24)`. 

The specific value of `row` and `column` changes every time the `grid` function is called, because these variables are calculated from the input argument `i`. Remember, `i` represents which number replication we're transforming. To calculate `column` and `row` we're going to use a few new KCL functions we haven't seen before.

Firstly, [`rem`]. The value `rem(i, divisor = n)` will divide i by n and return the remainder. This means that for i = 0, 1, 2, 3, 4, x will equal 0, 1, 2, 3 and 4. But when i = 5 (i.e. the fifth copy is being calculated), x will be 0. We're calling this function 25 times, and over those calls, x will step from 0 to 4, jump back down to 0, and begin stepping up again. This means x is a good way to calculate the columns, which range from column 0 to column 4 (a total of 5 columns).

The [`floor`] function takes a fractional number, and rounds it down to the nearest integer. For example, `floor(3.6)` is `3`. This means it's a good way to calculate the row, because the first five times it's called, `row` will always equal `0`. It'll round down `(i / n)` from `0/5`, `1/5`, `2/5`, `3/5`, `4/5` all down to `0`. Then the sixth time it's called, it will receive `5/5`, which is 1, and round it down to `1`. These neat little mathematical tricks mean we can calculate the row and column from the repetition number `i`.

The final result speaks for itself:

<!-- KCL: name=xform_grid,alt=Grid of tiles using a pattern transform-->

We can transform each replica in other ways, too. For example, we can skip a replica altogether! Let's make a chessboard pattern, where we skip every second tile. 

```kcl=xform_chessboard
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

numColumns = 5    // how many columns in our grid
width = 10        // side length of each square
gap = 1.05 * width // gap between each square

// Sketch a square
squareSketch = sketch(on = XY) {
  line1 = line(start = [var -1.35mm, var 1.51mm], end = [var 1.44mm, var 1.51mm])
  line2 = line(start = [var 1.44mm, var 1.51mm], end = [var 1.44mm, var -1.25mm])
  line3 = line(start = [var 1.44mm, var -1.25mm], end = [var -1.35mm, var -1.25mm])
  line4 = line(start = [var -1.35mm, var -1.25mm], end = [var -1.35mm, var 1.51mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
  equalLength([line1, line2, line3, line4])
  distance([line4.start, line4.end]) == width
}

// Transform function
fn grid(@i) {
  column = rem(i, divisor = numColumns)
  row = floor(i / numColumns)
  // Is `i` an even, or odd, number?
  isEven = rem(i, divisor = 2) == 0

  return {
    translate = [column * gap, row * gap, 0],
    // Only create a replica if `isEven` is true.
    replicate = isEven,
  }
}

// Extrude square, then pattern it using the transform function.
region(segments = [squareSketch.line1, squareSketch.line2])
  |> extrude(length = 2)
  |> patternTransform(instances = numColumns * numColumns, transform = grid)
```

In this example, we use a very similar transform function. The only difference is, we're setting the `replicate` property on the final transform too. And we're setting it to the variable `isEven`. This variable is a boolean value -- it's true if `i` divided by 2 has a remainder of 0, which is the definition of an even number (it's divisible by 2). This should skip every second replication. Let's try it out!

<!-- KCL: name=xform_chessboard,alt=chessboard of tiles using a pattern transform-->

Here's another example, with some different transform properties being set.

```kcl=cube_spiral
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

width = 10        // side length of each square

// Sketch a square
squareSketch = sketch(on = XY) {
  line1 = line(start = [var -1.35mm, var 1.51mm], end = [var 1.44mm, var 1.51mm])
  line2 = line(start = [var 1.44mm, var 1.51mm], end = [var 1.44mm, var -1.25mm])
  line3 = line(start = [var 1.44mm, var -1.25mm], end = [var -1.35mm, var -1.25mm])
  line4 = line(start = [var -1.35mm, var -1.25mm], end = [var -1.35mm, var 1.51mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
  equalLength([line1, line2, line3, line4])
  distance([line4.start, line4.end]) == width
}

fn transform(@i) {
  return {
    // Move down each time.
    translate = [0, 0, -i * width],
    // Make the cube longer, wider and flatter each time.
    scale = [
      pow(1.1, exp = i),
      pow(1.1, exp = i),
      pow(0.9, exp = i)
    ],
    // Turn by 15 degrees each time.
    rotation = { angle = 15 * i, origin = "local" }
  }
}


// Extrude square, then pattern it using the transform function.
region(segments = [squareSketch.line1, squareSketch.line2])
  |> extrude(length = 2)
  |> patternTransform(instances = 25, transform)
```

In this example, we make 25 cubes, slightly transforming each one. Each cube gets **translated** (moving down along the Z axis), and **scaled** (becoming longer, wider and flatter), as well as **rotating** 15 degrees around its own center (i.e. its **local** origin). We could rotate them around the scene's center by using `origin = "global"`. Here's the result.

<!-- KCL: name=cube_spiral,alt=many cubes in a spiral which gradually flattens each cube-->

The transform functions we've used so far each return a single transform. But if you'd like, they can return an array of transforms. Each transform in the array will get executed in order. This is helpful for simplifying some of your math calculations. Sometimes it's easier to formulate a transformation as a rotate, then a translate, then rotating back, rather than trying to calculate the perfect translation all at once.

Pattern transforms are a very powerful tool. They're definitely one of the most complex function in KCL, but that complexity gives you a lot of flexibility. Any mathematical curve you can formulate can be used to pattern your instances, by just calculating it in a transform function. The same goes for tiling or grid arrangements. For more examples, you can read the full [`patternTransform`] docs.

## 2D patterns and holes

> **WARNING**: This section is a KCL 1 maintenance reference. 2D patterns are
> currently supported only by the old sketch syntax, and `subtract2d` is
> deprecated as of KCL 2. New KCL 2 models should pattern solid cutters and use
> 3D [`subtract`] instead.

So far all of the patterns we've used have replicated 3D solids. But you can use patterns to replicate 2D sketches too. The [`patternLinear2d`], [`patternCircular2d`] and [`patternTransform2d`] functions work like their 3D variants, except they take 2D axes and 2D points. Here's a simple example:

```kcl=pattern2d
@settings(defaultLengthUnit = mm, kclVersion = 1.0)

manyCircles = startSketchOn(XZ)
  |> circle(radius = 4, center = [50, 0])
  |> patternCircular2d(
       center = [0, 0],
       instances = 12,
       arcDegrees = 360deg,
       rotateDuplicates = true,
     )
```

<!-- KCL: name=pattern2d,alt=Patterning 2D sketches of circles-->

Now, you could use these 2D patterns as the basis for 3D solids, by extruding or revolving them. You can see this by adding the line `extrude(manyCircles, length = 10)` to the end of the above KCL program. But it's not a good idea, because it produces the exact same model as you would have gotten from making a single 3D solid, then using 3D patterns on that. The only difference is, extruding a 2D pattern is much slower than patterning a 3D solid. So, can we do anything _useful_ with 2D patterns?

In existing KCL 1 models, the deprecated [`subtract2d`] function can put these
holes into a 2D sketch. The following example is retained for maintaining those
models, not as guidance for new KCL 2 code.

```kcl=subtract2d_patterns
@settings(defaultLengthUnit = mm, kclVersion = 1.0)

manyCircles = startSketchOn(XZ)
  |> circle(radius = 4, center = [50, 0])
  |> patternCircular2d(
       center = [0, 0],
       instances = 12,
       arcDegrees = 360deg,
       rotateDuplicates = true,
     )

base = startSketchOn(XZ)
  |> circle(radius = 60, center = [0, 0])
  |> subtract2d(tool = manyCircles)
  |> extrude(length = 10)
```

<!-- KCL: name=subtract2d_patterns,alt=Subtracting a pattern of circles then extruding-->

For new KCL 2 models, create one solid cutter, pattern that solid, and pass the
result to 3D [`subtract`]. Continue using [`subtract2d`] only when maintaining a
KCL 1 model that has not yet been migrated.

[`patternLinear3d`]: https://zoo.dev/docs/kcl-std/functions/std-solid-patternLinear3d
[`patternLinear2d`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-patternLinear2d
[`patternCircular3d`]: https://zoo.dev/docs/kcl-std/functions/std-solid-patternCircular3d
[`patternCircular2d`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-patternCircular2d
[`patternTransform`]: https://zoo.dev/docs/kcl-std/functions/std-solid-patternTransform
[`patternTransform2d`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-patternTransform2d
[`subtract`]: https://zoo.dev/docs/kcl-std/functions/std-solid-subtract
[`rem`]: https://zoo.dev/docs/kcl-std/functions/std-math-rem
[`floor`]: https://zoo.dev/docs/kcl-std/functions/std-math-floor
[`subtract2d`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-subtract2d
