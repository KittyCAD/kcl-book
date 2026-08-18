# Interop with other CAD programs

KCL tries to work well with the rest of the CAD ecosystem. That means you can use other CAD files and import them into KCL, or export your KCL to other formats for use with other CAD software. You can use the Zoo API or CLI to drive these conversions. Let's see how.

## Importing other files into KCL

The `import` statement lets you load models from other CAD files and use them in your KCL. Once imported, they can be translated, rotated, cloned etc. For example, let's import a shape from some CAD file. If you place a file named "car motor.step" in the root of your KCL project (i.e. next to `main.kcl`), you can run this:

```kcl
import "car motor.step" as motor
```

Once you've imported the geometry, it'll be placed in your scene. You can then move, rotate, scale, recolour, and clone it. For example, let's make two motors:

```kcl
import "car motor.step" as motor

motor
  |> translate(x=10)
clone(motor)
  |> translate(x=20)
```

## Exporting KCL into other formats

If you're writing KCL in the Zoo Design Studio, you can export your design into many different formats. Bring up the export menu via the Command Palette: just type Cmd+K on MacOS, or Ctrl+K on Windows/Linux. Type Export and press enter to choose the Export command. Then you can choose a format, and download your model! From there, you could import it into another CAD program, or send to a 3D printer or manufacturing service.

You can also use the [Zoo CLI]: just run

```sh
zoo kcl export --output-format gltf main.kcl model
Wrote file: model/output.gltf
```

Currently Zoo supports exporting and importing fbx, glb, gltf, obj, ply, step, and stl files.

## What you can't do with imported geometry

An import is *not* a KCL solid. It has its own type, `ImportedGeometry`, and there's no conversion between the two. `clone`, `translate`, `rotate`, `scale`, `appearance`, `hide`, and `delete` all accept an import, but nothing that expects a `Solid` does. That rules out `subtract`, `union`, `intersect`, `fillet`, `chamfer`, `shell`, the pattern functions, and `startSketchOn`.

So if you import that motor and try to subtract it from a housing you've modelled, KCL stops you before anything is built:

> The input argument of `subtract` requires one or more `Solid`s (`[Solid; 1+]`), but found an array of `ImportedGeometry`

This is about the type, not the file. A mesh format like STL has no surfaces to cut against, and a STEP file's BREP data isn't exposed to the modelling operations yet either, so both behave the same way.

If you need to cut into an imported part, or boolean it against something you've modelled, you have two options. Recreate the shape in KCL, using the import as an on-screen reference while you rebuild, then operate on the native solid. Or leave the import alone and model a separate part that fits it, positioning your new geometry with `translate` and `rotate`.
