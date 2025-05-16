# Types and Units
<!-- toc -->

KCL tracks the type of each variable, and can help you avoid bugs by noticing when your types don't match. You may have noticed the very basic type checking already, for example trying to run `3 * true` will cause an error. But KCL supports more helpful type checks. Let's see how!

## Function signatures

Consider this KCL example. 

```kcl
// Could take either two strings, or two numbers.
fn makeMessage(prefix, suffix) {
  return prefix + suffix
}

msg1 = makeMessage(prefix = "hello", suffix = " world")
msg2 = makeMessage(prefix = 1, suffix = 3)
```

In this example, `makeMessage` takes two arguments and adds them together with `+`. If the two arguments are both strings, like in `msg1`, this will produce one concatenated string (like `"hello world"`). If the two args are numbers (like in `msg2`) this will add them together (in the example, producing 4).

This might not be the goal, though! Maybe you designed `makeMessage` to only work with numbers, or only work with strings. You can add a type to the argument, and KCL will make sure it's only called with those arguments. Like this:

```kcl
// Note the types of arguments are given now.
fn makeMessage(prefix: string, suffix: string) {
  return prefix + suffix
}

msg1 = makeMessage(prefix = "hello", suffix = " world")
msg2 = makeMessage(prefix = 1, suffix = 3)
```

In this example, `msg1` is defined successfully as "hello world", but KCL will exit with an error while running `msg2`, because the arguments being passed to it don't match the types the function declares.

## Units of measurement

KCL tracks the units that each distance uses. This can help you accurately translate your engineering requirements or formula into KCL, without pulling out a calculator to convert between inches and centimeters.

For example, you can put a unit like `20cm` or `20in` as the length of a line. Here's three different lines of length 20 centimeters, inches and millimeters.

```kcl=lines_units
startSketchOn(XY)
  |> startProfile(at = [0, -100])
  |> xLine(length = 20mm)

startSketchOn(XY)
  |> startProfile(at = [0, 0])
  |> xLine(length = 20cm)

startSketchOn(XY)
  |> startProfile(at = [0, 100])
  |> xLine(length = 20in)
```

<!-- KCL: name=lines_units,skip3d=true,alt=Three lines of length 20 mm and 20 cm and 20 inches-->

Other suffixes include metres (`m`), feet (`ft`) and yards (`yd`).

In the previous examples, before this chapter, we always used general-purpose numbers with no units (like `length = 20`). Each KCL file has a default unit. You can set it by adding `@settings(defaultLengthUnit = in)` at the top of your KCL file. It has to go at the very top, before any code (although comments are permitted before it). If you don't set the default in `@settings`, your [user- or project-level settings] might set it. Otherwise, if you truly don't set anything, it'll default to millimeters. 

You can also set the units for angle measurements. Here's two toruses, one of which revolves 6 degrees (very little) and the other, 6 radians (almost a full revolution).


```kcl=donut_angle_units
// Revolve 6 degrees
startSketchOn(XZ)
  |> circle(center = [-200, -200], radius = 50)
  |> revolve(axis = Y, angle = 6deg)

// Revolve 6 radians
startSketchOn(XZ)
  |> circle(center = [200, 200], radius = 50)
  |> revolve(axis = Y, angle = 6rad)
```

<!-- KCL: name=donut_angle_units,alt=Revolve of 6 degrees vs. 6 radians-->

## Mixing units

When you're doing arithmetic in KCL, you can mix and match numbers:

```kcl
y = 3cm // roughly 1.18 inches
x = 10in - y
```

If you open the Variables pane, you'll see that `x` is 8.818 inches. KCL can track the numbers and types involved, letting you flexibly compare different units. However, KCL is not perfect at this (yet -- we're working on it!) For example, right now, KCL cannot anticipate what 30 inches multiplied by 2 centimeters is. If you try `30in * 2cm`, you'll get a warning: `Multiplying numbers which have unknown or incompatible units.` KCL warns you so that you can explicitly provide units if you want.

```kcl
// This causes a warning that KCL doesn't know what units `z` uses
z = 10in * 3cm
```

## Units and function signatures

You can combine units of measurement and types! There are 3 kinds of number type:

 - A specific unit, like `number(mm)` or `number(deg)`.
 - Some kind of number, like `number(Length)`, which accepts centimeters or inches, but not degrees or radians. Similarly, `number(Angle)` accepts degrees or radians, but not centimeters or inches.
 - Any kind of number, i.e. just `number`.

These can be used in function signatures. If you define a function that accepts, say, centimeters, and someone passes in inches, the inches will automatically be converted to centimeters. This works just like the above example of `10in - 3cm`, with the same limitations (sometimes you'll need to provide the type, like `x: number(cm)`).

Here's a user-defined function `f` that accepts some angle -- either degrees or radians, but not centimeters (which is a length, not an angle).

```kcl
fn f(theta: number(Angle)) {
  return cos(theta)
}

xArg = 360deg
x = f(theta = xArg)
yArg = (2 * PI): number(rad)
y = f(theta = yArg)
```

If you try to run `f(theta = 2in)` you'll see an error that explains you're using the wrong type of number. But both `x` and `y` will correctly be 1 if you open the Variables panel, showing that their units are being tracked correctly.

## Other types

Arrays and functions have their own type. You can look up these details at the [types page in our docs].

[user- or project-level settings]: https://zoo.dev/docs/kcl-lang/settings
[types page in our docs]: https://zoo.dev/docs/kcl-lang/types
