# Interop with other CAD programs

KCL tries to work well with the rest of the CAD ecosystem. That means you can use other CAD files and import them into KCL, or export your KCL to other formats for use with other CAD software. You can use the Zoo API or CLI to drive these conversions. Let's see how.

## Importing other files into KCL

The `import` statement lets you load models from other CAD files and use them in your KCL. Once imported, they can be translated, rotated, cloned etc. For example, let's import a shape from some CAD file.

```kcl
import "motor.step" as motor
```

Once you've imported the geometry, it'll be placed in your scene. You can then modify it like any other KCL solid. For example, let's make two motors:

```kcl
import "motor.step" as motor

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

[Zoo CLI]: https://zoo.dev/docs/cli/manual
