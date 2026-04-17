# Sketch on face

<!-- toc -->

In the previous chapter, we looked at how KCL lets you tag edges. Tags let you query your edges (to find their length, or angle with the previous edge), or apply an edge cut (like a fillet or chamfer). But you can tag more than just edges! In this chapter, we'll learn how to tag faces, and how that lets you build more complicated 3D models.

## Side faces

Let's start with a simple example. First, we'll sketch and extrude a triangle.

```kcl=triangle_for_sketching
// Make a triangle
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
region001 = region(point = [0.49mm, -4.1075mm], sketch = sketch001)
extrude001 = extrude(region001, length = 1)
```

<!-- KCL: name=triangle_for_sketching,alt=An extruded triangle -->

When our triangle is extruded, its 3 edges create 3 new side faces, one for each original edge. I like to imagine extrusion like an invisible hand grabbing the flat sketch and pulling it upwards into the third dimension, slowly stretching each edge until they expand to become faces. So, each new side face corresponds to an existing edge. And crucially, the faces are linked back to their parent edge. This means the face which grew out of the `line1` can be referred to via `extrude001.sketch.tags.line1`. We can use this to reference this face in our 3D model`.

Now, if we want to start a new sketch _on that face_, we can do so, with the `faceOf` function!

```kcl
myFace = faceOf(extrude001, face = region001.tags.line3)
sketch003 = sketch(on = myFace) {
  // We'll add lines to this sketch later.
}
```

In all the previous example sketches, we've sketched on a _plane_ (like XY or YZ). But now, we're passing a solid face (of our extruded triangle) instead. The solid has five faces (three side faces, a bottom, and a top), so we use `faceOf` to say which face in particular we want to sketch on. As we discussed above, the face can be referenced via `line1` (the line that it was extruded from). Now we can start sketching on this face, and even extrude that sketch too.


```kcl=triangle_with_cylinder_sketched
// Make a triangle
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
region001 = region(point = [0.49mm, -4.1075mm], sketch = sketch001)
extrude001 = extrude(region001, length = 1)

// Sketch on a face of the triangle.
face002 = faceOf(extrude001, face = region001.tags.line3)
sketch003 = sketch(on = face002) {
  line1 = line(start = [var -3.21mm, var 0mm], end = [var -2.7mm, var 0.65mm])
  horizontal([line1.start, ORIGIN])
  line2 = line(start = [var -2.7mm, var 0.65mm], end = [var -2.45mm, var 0.35mm])
  coincident([line1.end, line2.start])
  line3 = line(start = [var -2.45mm, var 0.35mm], end = [var -3.21mm, var 0mm])
  coincident([line2.end, line3.start])
  coincident([line3.end, line1.start])
}

// Extrude that sketch
region002 = region(point = [-2.9530332mm, 0.3234568mm], sketch = sketch003)
extrude002 = extrude(region002, length = 2)
```

<!-- KCL: name=triangle_with_cylinder_sketched,alt=Previous triangle now has a cylinder sketched on one side face-->

Great! We extruded a solid (the triangle), and could sketch on one of its faces, even extruding that sketch.

**Note**: When you sketch on a face, the sketch uses the _global coordinate system_. This means when you use 2D points in your sketches, they're relative to the overall global scene, and _not_ the face you're sketching on.

 Sketching on faces is a really common pattern when designing real-world objects. A LEGO brick is a good example -- first you'd sketch the rectangular brick, then you'd sketch on its top face, adding the little bumps on top. But wait a second. How would we specify the top face of the brick? That face isn't created from any particular edge. So we can't tag its `line` call and then reuse that tag for the face. What should we do?

## Standard faces

There's a simple solution to sketching on the top face. KCL has some built-in identifiers for the top and bottom face, [`END`] and [`START`]. We prefer the terms "start" and "end" to "top" and "bottom" because the latter depend on your camera angle, so they can be ambiguous. "Start" always refers to the original face from your 2D sketch. "End" always refers to the new face created at the end of the extrusion. Let's use them!

```kcl=triangle_top_and_bottom_sketches
// Same as previous example
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
region001 = region(point = [0.49mm, -4.1075mm], sketch = sketch001)
extrude001 = extrude(region001, length = 1)

// Changed: We're using `face = END` here, which is a built-in
// identifier for the end of an extrusion.
face002 = faceOf(extrude001, face = END)
sketch003 = sketch(on = face002) {
  line1 = line(start = [var -0.3mm, var 0.76mm], end = [var -1.26mm, var -1.25mm])
  line2 = line(start = [var -1.26mm, var -1.25mm], end = [var 1.68mm, var -1.14mm])
  coincident([line1.end, line2.start])
  line3 = line(start = [var 1.68mm, var -1.14mm], end = [var -0.3mm, var 0.76mm])
  coincident([line2.end, line3.start])
  coincident([line3.end, line1.start])
}

// Extrude that sketch
region002 = region(point = [-0.7777441mm, -0.2460774mm], sketch = sketch003)
extrude002 = extrude(region002, length = 1)

```

<!-- KCL: name=triangle_top_and_bottom_sketches,alt=Solid with a cylinder extruded on top and a cube extruded below-->

Great! These built-in face identifiers are always available on solids. We've learned how to sketch on the top, bottom and side faces. That covers all possible faces, right? Right? Not exactly! There's one more kind of face we haven't talked about yet. 

## Sketch on chamfer

When you [`chamfer`] an edge, it creates a new face, which can also be sketched on! Consider this chamfered cube from the previous chapter:

```kcl=chamfered_cube
// Same as previous examples
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(regionCube, length = width)

// Apply a chamfer
chamferedCube = chamfer(
  extrudeCube,
  tags = [getOppositeEdge(extrudeCube.sketch.tags.line1)],
  length = 0.2,
)
```

<!-- KCL: name=chamfered_cube,alt=A chamfered cube-->

The chamfer produced a new face, and we can sketch on it too. Firstly, we add a tag to the [`chamfer`] call. Then we can use it in `faceOf`, and then we can sketch on it like any other  face.

```kcl=sketch_on_chamfered_cube
// Same as previous examples
width = 1
square = sketch(on = XY) {
  line1 = line(start = [width / 2, -width / 2], end = [width / 2, width / 2])
  line2 = line(start = [width / 2, width / 2], end = [-width / 2, width / 2])
  line3 = line(start = [-width / 2, width / 2], end = [-width / 2, -width / 2])
  line4 = line(start = [-width / 2, -width / 2], end = [width / 2, -width / 2])
}
regionCube = region(point = [0.4975mm, 0mm], sketch = square)
extrudeCube = extrude(regionCube, length = width)

// Apply a chamfer
chamferedCube = chamfer(
  extrudeCube,
  tags = [getOppositeEdge(extrudeCube.sketch.tags.line1)],
  length = 0.2,
  // Add a tag to the chamfered face:
  tag = $myChamferedFace,
)

// Refer back to the tagged face
faceToSketchOn = faceOf(extrudeCube, face = myChamferedFace)

// Start sketching on that face.
triangle = sketch(on = faceToSketchOn) {
  line1 = line(start = [var -0.37mm, var 0.33mm], end = [var -0.2mm, var 0.47mm])
  line2 = line(start = [var -0.2mm, var 0.47mm], end = [var 0.26mm, var 0.29mm])
  coincident([line1.end, line2.start])
  line3 = line(start = [var 0.26mm, var 0.29mm], end = [var -0.37mm, var 0.33mm])
  coincident([line2.end, line3.start])
  coincident([line3.end, line1.start])
}
region001 = region(point = [-0.2834107mm, 0.3980702mm], sketch = triangle)
extrude001 = extrude(region001, length = 0.4)

```

<!-- KCL: name=sketch_on_chamfered_cube,alt=Chamfered cube with cylinder sketched on the chamfered face-->

So far, we've sketched on standard planes (like XY), on faces based on edges, and on standard faces like END. There's one more place you can start sketching on: a custom plane. Let's learn how.

## Defining new planes

We've previously sketched on standard planes like XY (remember, there are six -- XY, YZ, XZ, -XY, -YZ and -XZ). But you can easily define your own planes too! There's two ways:

### Offset planes

You can use the [`offsetPlane`] function to copy any other plane, but moved some direction up or down the third axis. For example, let's draw a small circle on XY, a medium circle on a plane 10 units above it, and a big circle 20 units above it.

```kcl=three_offset_planes
r = 10
sketch001 = sketch(on = XY) {
  circle1 = circle(start = [var -0.52mm, var 0.56mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  line1 = line(start = [var -0.52mm, var 0.56mm], end = [var 0mm, var 0mm], construction = true)
  coincident([line1.start, circle1.start])
  coincident([line1.end, circle1.center])
  distance([line1.start, line1.end]) == r
  vertical(line1)
}

// Note the `offsetPlane` call!
sketch002 = sketch(on = offsetPlane(XY, offset = 10)) {
  circle1 = circle(start = [var -0.52mm, var 0.56mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  line1 = line(start = [var -0.52mm, var 0.56mm], end = [var 0mm, var 0mm], construction = true)
  coincident([line1.start, circle1.start])
  coincident([line1.end, circle1.center])
  distance([line1.start, line1.end]) == r * 2
  vertical(line1)
}

// Another `offsetPlane` call, offset even further!
sketch003 = sketch(on = offsetPlane(XY, offset = 20)) {
  circle1 = circle(start = [var -0.52mm, var 0.56mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  line1 = line(start = [var -0.52mm, var 0.56mm], end = [var 0mm, var 0mm], construction = true)
  coincident([line1.start, circle1.start])
  coincident([line1.end, circle1.center])
  distance([line1.start, line1.end]) == r * 3
  vertical(line1)
}
```

<!-- KCL: name=three_offset_planes,alt=Circles on the XY plane and 10 above it and 20 above it-->

Offset planes are a quick and easy way to create new planes by using some other plane as a template. But what if you want to create a plane that actually points in a different direction, i.e. has different axes? What if you wanted to create a plane that was pointing at an unusual angle from the global X Y and Z axes? Let's try it.

### Custom planes

You can define your own plane with your own axes like this:

```kcl
customPlane = {
  origin = { x = 0, y = 1, z = 0},
  xAxis = { x = 1, y = 0, z = 0 },
  yAxis = { x = 0, y = 0, z = 1 },
}
```

Note the custom plane has a few properties:

 - An origin, which is a 3D point in space, using the global coordinate system (i.e. it's relative to the overall scene)
 - X and Y axes, which are defined as vectors

The plane's Z axis is the cross product of its X and Y axes. It's uniquely determined, so you don't need to specify it.

Now let's use this custom plane in a sketch. We'll build two identical cylinders, but one is on the standard XY plane, and one is on the custom plane we defined above.

```kcl=custom_plane
customPlane = {
  origin = {
    x = 0,
    y = 0,
    z = 0
  },
  xAxis = { x = 1, y = 0.5, z = 0 },
  yAxis = { x = 0, y = 0.5, z = 1 }
}

sketch001 = sketch(on = customPlane) {
  circle1 = circle(start = [var -0.52mm, var 0.56mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  line1 = line(start = [var -0.52mm, var 0.56mm], end = [var 0mm, var 0mm], construction = true)
  coincident([line1.start, circle1.start])
  coincident([line1.end, circle1.center])
  distance([line1.start, line1.end]) == 1
  vertical(line1)
}
```

<!-- KCL: name=custom_plane,alt=One cylinder on XY plane and another on a custom plane-->

Great! Custom planes give you a lot of power and flexibility. You can draw sketches in any orientation now. But they can be a bit verbose and complicated to define, so you should use [`offsetPlane`] if you've already defined a plane on the same X and Y axis. You can even combine `offsetPlane` and custom planes, like this:

```kcl
// Make a custom plane.
customPlane = {
  origin = { x = 0, y = 1, z = 0},
  xAxis = { x = 1, y = 0, z = 0 },
  yAxis = { x = 0, y = 0, z = 1 },
}
// Now offset it 20 up its normal axis.
newPlane = offsetPlane(customPlane, offset = 20)
```

Now we've learned how to sketch on all sorts of things:

 - Standard planes like XY or -XZ
 - Tagged faces of existing solids
 - Top or bottom faces of solids, using [`START`] and [`END`]
 - Chamfered faces cut out of solids, by tagging the [`chamfer`] call
 - Custom planes (truly custom, or just offset from an existing plane)

This gives you a lot of flexibility in building your solids. Now it's time to learn what else we can do with these solids. The next chapter will teach you how to combine and transform them!

[`END`]: <https://zoo.dev/docs/kcl-std/consts/std-END>
[`START`]: <https://zoo.dev/docs/kcl-std/consts/std-START>
[`chamfer`]: https://zoo.dev/docs/kcl-std/functions/std-solid-chamfer
[`faceOf`]: https://zoo.dev/docs/kcl-std/functions/std-sketch-faceOf
[`offsetPlane`]: <https://zoo.dev/docs/kcl-std/functions/std-offsetPlane>
