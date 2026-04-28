# Planes

<!-- toc -->

A plane is a 2D surface that exists in 3D space. KCL has its own [plane type], which is mostly used for starting a sketch. We've previously sketched on standard planes like XY (remember, there are six -- XY, YZ, XZ, -XY, -YZ and -XZ). But you can easily define your own planes too! We'll look at custom planes in this chapter.

## Offset planes

You can use the [`offsetPlane`] function to copy any other plane, but moved some direction up or down the third axis. For example, let's draw a small circle on XY, a medium circle on a plane 10 units above it, and a big circle 20 units above it.

```kcl=three_offset_planes
r = 10
sketch001 = sketch(on = XY) {
  circle1 = circle(start = [var -0.52mm, var 0.56mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  // Construction geometry line, used for the radius constraint.
  radiusLine = line(start = [var -0.52mm, var 0.56mm], end = [var 0mm, var 0mm], construction = true)
  coincident([radiusLine.start, circle1.start])
  coincident([radiusLine.end, circle1.center])
  // Constrain the circle's radius.
  distance([radiusLine.start, radiusLine.end]) == r
  vertical(radiusLine)
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

## Custom planes

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

The plane's Z axis is the cross product of its X and Y axes. It's uniquely determined, so you don't need to specify it. The Z axis respects the [right-hand rule].

Now let's use this custom plane in a sketch. We'll build two identical cylinders, but one is on the standard XY plane, and one is on the custom plane we defined above.

```kcl=custom_plane
customPlane = {
  origin = { x = 0, y = 6, z = 0 },
  xAxis = { x = 1, y = 0.5, z = 0 },
  yAxis = { x = 0, y = 0.5, z = 1 }
}

// Build a cylinder on a custom plane
sketch001 = sketch(on = customPlane) {
  circle1 = circle(start = [var -0.52mm, var 0.56mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  line1 = line(start = [var -0.52mm, var 0.56mm], end = [var 0mm, var 0mm], construction = true)
  coincident([line1.start, circle1.start])
  coincident([line1.end, circle1.center])
  distance([line1.start, line1.end]) == 1
  vertical(line1)
}
region001 = region(point = [0mm, -0.9975mm], sketch = sketch001)
extrude001 = extrude(region001, length = 2)

// Build the same cylinder, but on the XY plane.
sketch002 = sketch(on = XY) {
  circle1 = circle(start = [var -0.52mm, var 0.56mm], center = [var 0mm, var 0mm])
  coincident([circle1.center, ORIGIN])
  line1 = line(start = [var -0.52mm, var 0.56mm], end = [var 0mm, var 0mm], construction = true)
  coincident([line1.start, circle1.start])
  coincident([line1.end, circle1.center])
  distance([line1.start, line1.end]) == 1
  vertical(line1)
}
region002 = region(point = [0mm, -0.9975mm], sketch = sketch002)
extrude002 = extrude(region002, length = 2)
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

## planeOf

There's one last method to create a plane: via the [`planeOf`] function. You can choose some 3D solid in your KCL file, and get the plane that its face lies on using `planeOf(mySolid, face = myFace)`. For example:

```kcl
// Make a square
sketch001 = sketch(on = XY) {
  line1 = line(start = [var -1.53mm, var -1.41mm], end = [var 1.99mm, var -1.41mm])
  line2 = line(start = [var 1.99mm, var -1.41mm], end = [var 1.99mm, var 1.42mm])
  line3 = line(start = [var 1.99mm, var 1.42mm], end = [var -1.53mm, var 1.42mm])
  line4 = line(start = [var -1.53mm, var 1.42mm], end = [var -1.53mm, var -1.41mm])
  coincident([line1.end, line2.start])
  coincident([line2.end, line3.start])
  coincident([line3.end, line4.start])
  coincident([line4.end, line1.start])
  parallel([line2, line4])
  parallel([line3, line1])
  perpendicular([line1, line2])
  horizontal(line3)
}
region001 = region(point = [0.23mm, -1.4075mm], sketch = sketch001)

// Make an arc to sweep the square along
sketch002 = sketch(on = YZ) {
  line1 = line(start = [var 0mm, var 0mm], end = [var 0mm, var 2.39mm])
  coincident([line1.start, ORIGIN])
  vertical([line1.end, ORIGIN])
  arc1 = arc(start = [var 0mm, var 2.39mm], end = [var -2.32mm, var 5.96mm], center = [var -3.91mm, var 2.39mm])
  coincident([line1.end, arc1.start])
  tangent([line1, arc1])
}

// Sweep the square along the arc
sweep001 = sweep(region001, path = [sketch002.line1, sketch002.arc1])

// Store the plane at the end of the sweep
p = planeOf(sweep001, face = END)
```

This plane can be used for sketching on, or altered with [`offsetPlane`].

We've covered three different ways to create planes:
 - Offsetting from an existing plane
 - Manually defining a plane with axes and an origin
 - Using the plane of a face.

Combined with the six standard planes, you have a wide range of planes that you can use to sketch on, or build solids with. In the next chapter, we'll look at how to manipulate and change those solids.

[`offsetPlane`]: <https://zoo.dev/docs/kcl-std/functions/std-offsetPlane>
[`planeOf`]: <https://zoo.dev/docs/kcl-std/functions/std-sketch-planeOf>
[plane type]: <https://zoo.dev/docs/kcl-std/types/std-types-Plane>
[right-hand rule]: <https://en.wikipedia.org/wiki/Right-hand_rule>
