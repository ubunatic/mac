# Minimal Statusbar App
Started from the CLI as script
```bash
swift mini.swfit
```
This is the simplest form of a GUI app in Swift that you can deliver.

No need to `swift build` or define package details.
You need to avoid dependencies though 🤔.

[Mousepaste](../Mousepaste) moved away fromn this style, since it uses
depoendencies and subpackages and external resources. The leanest alternative to this script-based approach is to `swift build` your app, then copy the whole `Myapp.app` dir to, e.g., `/opt`, run it from the resulting binary dir, e.g., `/opt/myapp/Myapp.app/Contents/MacOS`.