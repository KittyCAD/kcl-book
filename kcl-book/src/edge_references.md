# Edge references

<!-- toc -->

## Why edges are described by faces

An edge reference is a topological query based on faces. Faces are more stable and predictable than edges, so deriving an edge from its surrounding faces provides a more robust API for selecting it. Even in complex CSG operations, the number of edges created is difficult to predict, while faces are transferred through the operation and their sources are known.

An edge reference starts with `sideFaces`: the faces adjacent to each side of the edge. It can add `endFaces` and, rarely, an `index` until the reference identifies exactly one intended edge. Operations such as `fillet`, `chamfer`, `revolve`, `helix`, and `mirror3d` all use the same reference shape.

The following examples show when each part of an edge reference is needed.

## Two side faces

If we take a simple extruded rectangle, each edge is uniquely identified by two side faces. The four walls are available through the region's sketch-segment tags, while `tagStart` and `tagEnd` identify the two caps.

```kcl=edge_reference_side_faces
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

square = sketch(on = XY) {
  bottom = line(start = [0, 0], end = [20, 0])
  right = line(start = [20, 0], end = [20, 20])
  top = line(start = [20, 20], end = [0, 20])
  left = line(start = [0, 20], end = [0, 0])
}
squareRegion = region(point = [10, 10], sketch = square)
cube = extrude(
  squareRegion,
  length = 20,
  tagStart = $startCap,
  tagEnd = $endCap,
)

gdt::annotation(
  edges = [{ sideFaces = [squareRegion.tags.bottom, endCap] }],
  annotation = "Two side faces",
  framePosition = [12, 8],
  fontSize = 3.5,
)

hide(square)
```

<div class="kcl-static-dark">

<!-- KCL: name=edge_reference_side_faces,skip3d=true,alt=An annotation pointing to the edge shared by a cube's bottom wall and end cap -->

</div>

The order of the two faces does not matter. In the example above, the edge is identified by the sketch-segment tag `bottom` and the cap tag `endCap`. Any edge on this cube can be identified by using the appropriate pair of face tags.

## Split edges and one end face

A modeling operation can split an edge into multiple edges. These edges can have the same two side faces, so more information is needed to disambiguate a single edge. This is where we use `endFaces`: faces that touch the ends of the edge rather than its two adjacent sides.

```kcl=edge_reference_one_end_face
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

sketch001 = sketch(on = XZ) {
  line1 = line(start = [0.8, 0.57], end = [4.38, 0.43])
  line2 = line(start = [4.38, 0.43], end = [2.16, 4.94])
  line3 = line(start = [2.16, 4.94], end = [0.8, 0.57])
}
region001 = region(segments = [sketch001.line3, sketch001.line1])
extrude001 = extrude(region001, length = 5, tagStart = $capStart001)

sketch002 = sketch(on = -YZ) {
  line1 = line(start = [0.96, 6.38], end = [2.59, 2.41])
  line2 = line(start = [2.59, 2.41], end = [3.4, 6.25])
  line3 = line(start = [3.4, 6.25], end = [0.96, 6.38])
}
region002 = region(segments = [sketch002.line3, sketch002.line1])
extrude002 = extrude(region002, length = -20)
solid001 = subtract(extrude001, tools = extrude002)

gdt::annotation(
  edges = [{
    sideFaces = [region001.tags.line2, region001.tags.line3],
    endFaces = [capStart001],
  }],
  annotation = "One end face",
  framePosition = [4, 3],
  fontSize = 1,
)

hide(sketch001)
hide(sketch002)
```

<div class="kcl-static-dark">

<!-- KCL: name=edge_reference_one_end_face,skip3d=true,alt=An annotation pointing to one of two split edges selected with one end face -->

</div>

Here, `capStart001` touches the intended edge, so adding it narrows the result to the single edge we want.

Some operations deliberately accept a reference that matches several edges. For example, omitting `endFaces` from this model lets one `fillet` reference apply to both edges shared by the two side faces. As you can see, both edges are filleted as a result:

```kcl=edge_reference_multiple_matches
@settings(defaultLengthUnit = mm, kclVersion = 2.0, experimentalFeatures = allow)

sketch001 = sketch(on = XZ) {
  line1 = line(start = [0.8, 0.57], end = [4.38, 0.43])
  line2 = line(start = [4.38, 0.43], end = [2.16, 4.94])
  line3 = line(start = [2.16, 4.94], end = [0.8, 0.57])
}
region001 = region(segments = [sketch001.line3, sketch001.line1])
extrude001 = extrude(region001, length = 5)

sketch002 = sketch(on = -YZ) {
  line1 = line(start = [0.96, 6.38], end = [2.59, 2.41])
  line2 = line(start = [2.59, 2.41], end = [3.4, 6.25])
  line3 = line(start = [3.4, 6.25], end = [0.96, 6.38])
}
region002 = region(segments = [sketch002.line3, sketch002.line1])
extrude002 = extrude(region002, length = -20)
solid001 = subtract(extrude001, tools = extrude002)

fillet001 = fillet(
  solid001,
  edges = [{
    sideFaces = [region001.tags.line2, region001.tags.line3]
  }],
  radius = 0.2,
)

hide(sketch001)
hide(sketch002)
```

<!-- KCL: name=edge_reference_multiple_matches,alt=Both split edges filleted by one reference containing only their shared side faces -->

## Two end faces

One end face is not always enough to resolve a single edge. In the following model, the two side faces meet along three edges. Each circular cutter touches two of them, so both end faces are required to identify the middle edge.

```kcl=edge_reference_two_end_faces
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

circleSketch = sketch(on = -XZ) {
  circle1 = circle(start = [5.65, 5.03], center = [3.75, 3.53])
}
circleRegion = region(segments = [circleSketch.circle1])
cylinder = extrude(circleRegion, length = 5)

wedgeSketch = sketch(on = YZ) {
  line1 = line(start = [0.53, -1.43], end = [2.31, 3.36])
  line2 = line(start = [2.31, 3.36], end = [5.04, -2.99])
  line3 = line(start = [5.04, -2.99], end = [0.53, -1.43])
}
wedgeRegion = region(segments = [wedgeSketch.line1, wedgeSketch.line2], direction = CW)
wedge = extrude(wedgeRegion, length = -20)
solid001 = intersect([wedge, cylinder])

cutSketch = sketch(on = -XZ) {
  line1 = line(start = [var 1.32, var 3.62], end = [var 3.47, var 3.7])
  line2 = line(start = [var 3.85, var 3.56], end = [var 5.7, var 3.53])
  arc1 = arc(start = [var 4.04, var 3.56], end = [var 5.39, var 3.54], center = [var 4.72, var 3.82])
  coincident([arc1.start, line2])
  coincident([arc1.end, line2])
  arc2 = arc(start = [var 1.67, var 3.63], end = [var 3.18, var 3.69], center = [var 2.42, var 3.83])
  coincident([arc2.start, line1])
  coincident([arc2.end, line1])
}
cutRegion1 = region(segments = [cutSketch.arc1, cutSketch.line2])
cut1 = extrude(cutRegion1, length = 5)
cutRegion2 = region(segments = [cutSketch.arc2, cutSketch.line1])
cut2 = extrude(cutRegion2, length = 5)
solid002 = subtract(solid001, tools = cut1)
solid003 = subtract(solid002, tools = cut2)

gdt::annotation(
  edges = [{
    sideFaces = [wedgeRegion.tags.line1, wedgeRegion.tags.line2],
    endFaces = [cutRegion1.tags.arc1, cutRegion2.tags.arc2],
  }],
  annotation = "Two end faces",
  framePosition = [4, 3],
  fontSize = 0.5,
)

hide(circleSketch)
hide(wedgeSketch)
hide(cutSketch)
```

<div class="kcl-static-dark">

<!-- KCL: name=edge_reference_two_end_faces,skip3d=true,alt=An annotation pointing to the middle of three edges selected using two end faces -->

</div>

The first end face rules out one candidate and the second rules out the other. Together with the side faces, they leave exactly one edge.

## Final disambiguation with `index`

In rare topology, multiple edges can share every useful side and end face. Face information cannot distinguish those edges, so `index` selects one from the remaining matches using a zero-based index.

```kcl=edge_reference_index
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

circleSketch = sketch(on = -XZ) {
  circle1 = circle(start = [5.65, 5.03], center = [3.75, 3.53])
}
circleRegion = region(segments = [circleSketch.circle1])
cylinder = extrude(circleRegion, length = 5)

wedgeSketch = sketch(on = YZ) {
  line1 = line(start = [0.53, -1.43], end = [2.31, 3.36])
  line2 = line(start = [2.31, 3.36], end = [5.04, -2.99])
  line3 = line(start = [5.04, -2.99], end = [0.53, -1.43])
}
wedgeRegion = region(segments = [wedgeSketch.line1, wedgeSketch.line2], direction = CW)
wedge = extrude(wedgeRegion, length = -20)
solid001 = intersect([wedge, cylinder])

cutSketch = sketch(on = -XZ) {
  line1 = line(start = [var 1.32, var 3.62], end = [var 3.47, var 3.7])
  line2 = line(start = [var 3.85, var 3.56], end = [var 5.7, var 3.53])
  arc1 = arc(start = [var 4.04, var 3.56], end = [var 5.39, var 3.54], center = [var 4.72, var 3.82])
  coincident([arc1.start, line2])
  coincident([arc1.end, line2])
}
cutRegion = region(segments = [cutSketch.arc1, cutSketch.line2])
cut = extrude(cutRegion, length = 5)
solid002 = subtract(solid001, tools = cut)

gdt::annotation(
  edges = [{
    sideFaces = [wedgeRegion.tags.line1, wedgeRegion.tags.line2],
    index = 1,
  }],
  annotation = "Index 1",
  framePosition = [4, 3],
  fontSize = 0.8,
)

hide(circleSketch)
hide(wedgeSketch)
hide(cutSketch)
```

<div class="kcl-static-dark">

<!-- KCL: name=edge_reference_index,skip3d=true,alt=An annotation pointing to one of two edges that share all surrounding faces -->

</div>

You should always prefer face information to uniquely identify an edge and use `index` only in the rare geometry where it is needed. A face-based reference is more semantic and therefore provides a more robust topological query for the edge.

## Surface edges

A surface body does not enclose a volume, so its boundary edges do not always have two side faces or useful end faces. A surface edge reference therefore uses a single side face and relies on `index` more often:

```kcl=surface_edge_reference
@settings(defaultLengthUnit = mm, kclVersion = 2.0)

surfaceSketch = sketch(on = XY) {
  source = line(start = [0, 0], end = [20, 0])
}
surface = extrude(
  surfaceSketch.source,
  length = 10,
  bodyType = SURFACE,
  method = NEW,
)

gdt::annotation(
  edges = [{
    sideFaces = [surface.sketch.tags.source],
    index = 1,
  }],
  annotation = "Surface edge",
  framePosition = [8, 5],
  fontSize = 2,
)

hide(surfaceSketch)
```

<div class="kcl-static-dark">

<!-- KCL: name=surface_edge_reference,skip3d=true,alt=An annotation pointing to a boundary edge of an extruded surface -->

</div>
