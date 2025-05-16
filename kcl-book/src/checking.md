<!-- toc -->
# Checking your work

Correctness matters a lot in engineering. KCL tries to give you the tools you need to check your own work, and make sure your designs do exactly what you expect. In this chapter we'll explore ways to verify your KCL code does what you intended it to do.

## Querying calculations

We've already covered this one, so I'll keep this brief. If you want to double-check your calculations, you can always assign some intermediate value to a variable, then view its value in the Variables panel in Zoo Design Studio. We saw an example of this earlier, where we broke up the quadratic equation [into parts and inspected them]. You can break complicated calculations into smaller parts, storing them in variables so they can be inspected individually.

## Querying geometry

You can also query distances and angles, by [measuring them with tags]. Then you can assign those values to variables and read them off the Variables panel. We covered this previously, so refer back to that link for more detail.

## Asserts

KCL's [`assert`] function lets you check that a certain variable has the expected value. In other words, you're asserting that the variable actually has the value you expect. If this assertion is wrong, KCL will stop executing and explain why. For example, let's add asserts to our quadratic equation calculations. We can calculate that the quadratic 2x^2 + 3x + 1 should have roots -0.5 and -1. Let's calculate it, and asserts to make sure we got the calculations correct.

```kcl
// Coefficients that define the quadratic
a = 2
b = 3
c = 1

delta = pow(b, exp = 2) - (4 * a * c)
x0 = ((-b) + sqrt(delta)) / (2 * a)
x1 = ((-b) - sqrt(delta)) / (2 * a)

// Assert the two roots are what we expect.
assert(x0, isEqualTo = -0.5)
assert(x1, isEqualTo = -1)
```
This program was written correctly, so the KCL program runs just fine. But let's pretend we made a typo. We'll change `c = 1` to `c = 0`, and rerun the program. You'll see the `assert` has an error now: "assert failed: Expected 0 to be equal to -0.5 but it wasn't".

Asserts work pretty similarly to looking up a variable in the Variables panel. Both let you check a value is what you expect. But asserts have two big advantages over checking the Variables panel.

Firstly, asserts are automatic. You can add asserts to your KCL code, and then every time the program runs, the asserts will get checked. You don't have to remember which values need checking. If you send your KCL file to a coworker, you don't have to explain "Hey, make sure to check that `maximumStress` is 1.25". You can just add the `assert` to your code, and all your coworkers will benefit from having the assertion checked. This is especially helpful for iterating on your design. You can start your design work by adding some asserts to check key requirements, and then as you keep tweaking and improving your design, KCL will automatically run all the asserts, and make sure the same properties are always checked.

Secondly, asserts are more flexible. You can check many different properties besides just checking two numbers are equal. For example, you can compare them and check if one number is greater or less than your variable:

```kcl
wallMountingHoleDiameter = .625
wallMountLength = 2.25
assert(wallMountLength, isGreaterThanOrEqual = wallMountingHoleDiameter * 3)
```

You can add custom error messages to explain _why_ this assertion is important:

```kcl
wallMountingHoleDiameter = .625
wallMountLength = 2.25
assert(wallMountLength, isGreaterThanOrEqual = wallMountingHoleDiameter * 3, error = "This doesn't leave enough room for a hole. Either decrease hole diameter or increase wallMountLength")
```

You can also add a tolerance to your equality checks, to ensure that tiny little differences caused by floating-point math or approximation calculations don't trigger the error.

```kcl
assert(1.0000001214, isEqualTo = 1.0, tolerance = 0.001)
```

## Asserts and parametric design

For a realistic example of asserts, see this [bracket] we modelled in KCL. You can see the mechanical engineer designed this parametrically. They designed the bracket in terms of parameters like `width`, `p` (the force on the shelf), `shelfMountLength` etc. From these initial parameters, they calculate other quantities, like the `moment` or the `thickness`. Then they use `asserts` to make sure that when the parameters are changed, the results are still sensible. For example, they check that the parameters leave enough of a gap between the holes and the bracket's edge. They're also checking that the bracket is strong enough, by checking the actual stress on the model for these parameters (`actualSigma`) is below the maximum allowed stress, via `assert(actualSigma, isLessThanOrEqual = sigmaAllow)`.

```kcl=bracket
// Shelf Bracket
// This is a bracket that holds a shelf. It is made of aluminum and is designed to hold a force of 300 lbs. The bracket is 6 inches wide and the force is applied at the end of the shelf, 12 inches from the wall. The bracket has a factor of safety of 1.2. The legs of the bracket are 5 inches and 2 inches long. The thickness of the bracket is calculated from the constraints provided.

// Set units
@settings(defaultLengthUnit = in, kclVersion = 1.0)

// Define parameters
sigmaAllow = 35000 // psi (6061-T6 aluminum)
width = 5.0
p = 300 // Force on shelf - lbs
fos = 1.2 // Factor of safety of 1.2
shelfMountLength = 5.0
wallMountLength = 2.25
shelfDepth = 12 // Shelf is 12 inches deep from the wall
shelfMountingHoleDiameter = .50
wallMountingHoleDiameter = .625

// Calculated parameters
moment = shelfDepth * p // assume the force is applied at the end of the shelf
thickness = sqrt(moment * fos * 6 / (sigmaAllow * width)) // required thickness for two brackets to hold up the shelf
bendRadius = 0.25
extBendRadius = bendRadius + thickness
filletRadius = .5
shelfMountingHolePlacementOffset = shelfMountingHoleDiameter * 1.5
wallMountingHolePlacementOffset = wallMountingHoleDiameter * 1.5

// Compute bending stress, rectangular section. 
// Assign single-letter variables to make transcribing the math equation easier.
m = moment
d = thickness
b = width
moi = (b * d^3)/12
c = d/2 // Distance to neutral axis.
actualSigma = (moment * c) / moi
assert(actualSigma, isLessThanOrEqual = sigmaAllow)

// Add checks to ensure bracket is possible. These make sure that there is adequate distance between holes and edges.
assert(wallMountLength, isGreaterThanOrEqual = wallMountingHoleDiameter * 3, error = "Holes not possible. Either decrease hole diameter or increase wallMountLength")
assert(shelfMountLength, isGreaterThanOrEqual = shelfMountingHoleDiameter * 5.5, error = "wallMountLength must be longer for hole sizes to work. Either decrease mounting hole diameters or increase shelfMountLength")
assert(width, isGreaterThanOrEqual = shelfMountingHoleDiameter * 5.5, error = "Holes not possible. Either decrease hole diameter or increase width")
assert(width, isGreaterThanOrEqual = wallMountingHoleDiameter * 5.5, error = "Holes not possible. Either decrease hole diameter or increase width")

// Create the body of the bracket
bracketBody = startSketchOn(XZ)
  |> startProfile(at = [0, 0])
  |> xLine(length = shelfMountLength - thickness, tag = $seg01)
  |> yLine(length = thickness, tag = $seg02)
  |> xLine(length = -shelfMountLength, tag = $seg03)
  |> yLine(length = -wallMountLength, tag = $seg04)
  |> xLine(length = thickness, tag = $seg05)
  |> line(endAbsolute = [profileStartX(%), profileStartY(%)], tag = $seg06)
  |> close()
  |> extrude(length = width)

// Add mounting holes to mount to the shelf
shelfMountingHoles = startSketchOn(bracketBody, face = seg03)
  |> circle(
       center = [
         -(bendRadius + shelfMountingHolePlacementOffset),
         shelfMountingHolePlacementOffset
       ],
       radius = shelfMountingHoleDiameter / 2,
     )
  |> patternLinear2d(instances = 2, distance = -(extBendRadius + shelfMountingHolePlacementOffset) + shelfMountLength - shelfMountingHolePlacementOffset, axis = [-1, 0])
  |> patternLinear2d(instances = 2, distance = width - (shelfMountingHolePlacementOffset * 2), axis = [0, 1])
  |> extrude(%, length = -thickness - .01)

// Add mounting holes to mount to the wall
wallMountingHoles = startSketchOn(bracketBody, face = seg04)
  |> circle(
       center = [
         wallMountLength - wallMountingHolePlacementOffset - bendRadius,
         wallMountingHolePlacementOffset
       ],
       radius = wallMountingHoleDiameter / 2,
     )
  |> patternLinear2d(instances = 2, distance = width - (wallMountingHolePlacementOffset * 2), axis = [0, 1])
  |> extrude(%, length = -thickness - 0.1)

// Apply bends
fillet(bracketBody, radius = extBendRadius, tags = [getNextAdjacentEdge(seg03)])
fillet(bracketBody, radius = bendRadius, tags = [getNextAdjacentEdge(seg06)])

// Apply corner fillets
fillet(
  bracketBody,
  radius = filletRadius,
  tags = [
    seg02,
    getOppositeEdge(seg02),
    seg05,
    getOppositeEdge(seg05)
  ],
)
```

<!-- KCL: name=bracket,alt=Parametric bracket with asserts to ensure parameters make sense-->

We could add more detailed checks by asserting that the parameters meet basic logical requirements -- for example, the `width` must be greater than zero to be meaningful. So you could add `assert(width, isGreaterThan = 0)`.


## Summary

KCL helps you automatically check your work. You should be able to analyze your engineering designs as early as possible in the design process -- ideally, within Zoo Design Studio, long before you send the part away for manufacturing or analysis. You can check your work in the Variables panel, but we recommend adding [`assert`] statements to your KCL. You can use asserts to:

 - Double-check your calculations, especially when transcribing engineering calculations into KCL
 - Validate parameters in parametric design, like ensuring a radius or length is positive
 - Check that your part fulfills its requirements, for example by calculating the maximum force it can tolerate, and asserting that maximum force is above your required minimum
 - Query geometry like the angle between two lines with [`segAng`] and ensure it's what you expect

[into parts and inspected them]: calling_functions.html#combining-functions
[measuring them with tags]: tags.html#measuring-with-tags
[`assert`]: https://zoo.dev/docs/kcl-std/assert
[`segAng`]: https://zoo.dev/docs/kcl-std/segAng
[bracket]: https://zoo.dev/docs/kcl-samples/bracket
