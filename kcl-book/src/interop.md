# Interop with other CAD programs

KCL tries to work well with the rest of the CAD ecosystem. That means you can use other CAD files and import them into KCL, or export your KCL to other formats for use with other CAD software. You can use the Zoo API or CLI to drive these conversions. Let's see how.

## Importing other files into KCL

The `import` statement lets you load models from other CAD files and use them in your KCL. Once imported, they can be translated, rotated, cloned etc. For example, let's import a shape from some CAD file. If you place a file named "car motor.step" in the root of your KCL project (i.e. next to `main.kcl`), you can run this:

```kcl
import "car motor.step" as motor
```

Once you've imported the geometry, it'll be placed in your scene, and referred to with its variable name, `motor`. Many (but not all) KCL functions accept imported geometry, and treat it like regular geometry made inside KCL. For example, let's make two motors:

```kcl
import "car motor.step" as motor

motor
  |> translate(x=10)
clone(motor)
  |> translate(x=20)
```

If a KCL function doesn't support imported geometry, its type signature will say so. For example, our CSG operations like [`subtract`](https://zoo.dev/docs/kcl-std/functions/std-solid-subtract#docs-page-top) don't support the `ImportedGeometry` type, because their type signature explicitly says it only takes `Solid` as a parameter. If you try to use one of them with imported geometry, you'll get a type error, something like:

```
> The input argument of `subtract` requires one or more `Solid`s (`[Solid; 1+]`), but found an array of `ImportedGeometry`
```

On the other hand, [`clone`](https://zoo.dev/docs/kcl-std/functions/std-clone#docs-page-top) supports imported geometry, as seen above. If you read the docs for `clone`, its parameters say you can clone a sketch, or solid, or imported geometry. If you want to use imported geometry for an operation that doesn't support it, your best bet is to import the geometry and then recreate it in KCL, using the original imported geometry as a visual reference.

## Exporting KCL into other formats

If you're writing KCL in the Zoo Design Studio, you can export your design into many different formats. Bring up the export menu via the Command Palette: just type Cmd+K on MacOS, or Ctrl+K on Windows/Linux. Type Export and press enter to choose the Export command. Then you can choose a format, and download your model! From there, you could import it into another CAD program, or send to a 3D printer or manufacturing service.

You can also use the [Zoo CLI]: just run

```sh
zoo kcl export --output-format gltf main.kcl model
Wrote file: model/output.gltf
```

Currently Zoo supports exporting and importing fbx, glb, gltf, obj, ply, step, and stl files.

[Zoo CLI]: https://zoo.dev/docs/cli/manual
