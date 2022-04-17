# Mousepaste
MacOS system-wide capturing of mouse-selection
to provide Linux-style middle-mouse pasting feature.

Implemented in plain Swift, runnable as single-file Swift script, developed using VSCode without requiring XCode.

## Usage
Copy [script/mousepaste.swift](script/mousepaste.swift) anywhere you want and run it.
```bash
./mousepaste.swift
```

### Options
```
➜ ./mousepaste.swift help
usage: ./mousepaste.swift [nogui|help] [-debug]
```

### User Interface
If running without the `nogui` flag, a small UI is added to the menu bar to manage the app.

The UI can start and stop Mousepaste's global event monitor,
disable and enabled debug logs on the console, and of course quit the app.

No preferences and icons yet.

## Why?
1. Nothing is faster than implicitly copying +
   pasting with the middle mouse button.
2. Once you are used to it, you can't live without.
3. Other tools that implement this on MacOS
   are not open-source and not small.
4. Do one thing and do it well.

## Requirements
* MacOS (of course)
* Swift (unless you want to use the precompiled versions)
* No XCode required!

Why no XCode? Because Swift has (nearly) all the tools you need,
and XCode easts up a ton of disk space.
Apple should not make it a requirement to build Swift packages.
This project just uses `make` and some tricks to manage all
Swift code without XCode.

## Development
To `swift build` this project without XCode, you must put a fake `xctest`
on your `PATH` (e.g., an empty shell script). This is needed since `swift`
uses `xcrun` which then looks for `xctest` to run any package tests
(even when there are no test).

To allow running, building, and testing with plain `swift`, some magic happens
in [generate.sh](generate.sh), which grabs all swift sources to `cat` them to
one executable file (incl. shebang). The result is [script/mousepaste.swift](script/mousepaste.swift), which you can build and directly run using:
```bash
make script
script/mousepaste.swift
```

### Installing Swift
If you installed Apple's Command Line Tools you may have a recent Swift version installed.
If this does not work with your IDE of choice (e.g., no cross-file code navigation in your package)
then try  one of the following.
```
brew install swift
```
In VSCode, set the toolchain path of the swift plugin to point to the installation, e.g., to the Homebrew installation:
* Swift: Path: `/opt/homebrew/opt/swift/bin`
* Swift: Toolchain Path: `/opt/homebrew/opt/swift/Swift-5.6.xctoolchain`

VSCode will complain if it cannot not start the language server. Try to navigate from package code in one file to another, e.g., from the [main.swift](Sources/Mousepaste/main.swift) code to any of the referenced classes via `CMD+click`.

## Testing
To test your changes, just `DEBUG=1 make run` the app and test it.
Make sure it works in some native Apps, in Chromium-based browsers, and in Electron Apps.

### Tested Apps
Mousepaste was successfully tested with the follwing apps.

| App           | Selection Type | Comment |
| ------------- | -------------- | ------- |
| Script Editor | AX             |         |
| Brave         | AX             |         |
| Slack         | AX             |         |
| KeepassXC     | AX             |         |
| iTerm2        | AX             | Disable iTerms own Copy Selection to avoid leaving selections on the Pasteboard. |
| Terminal      | AX             |         |
| Finder        | AX             | Currently also file names are copied if you click too fast (detected as double click). |
| Notes         | AX             |         |
| Safari        | `Cmd+C`        |         |
| VSCode        | `Cmd+C`        | Electron Apps still have limited AX support on MacOS. AX support possible via screen reader mode (`Alt+F1`, `Cmd+E`, `Shift+Esc`, but beware of the assistive AX sounds and disabled word wrap that come with that feature. |

### Compatibility
The following Pastboard apps are compatible with Mousepaste.

| App           | Status         | Comment |
| ------------- | -------------- | --------|
| Flycut        | no issues      | mouse selection is ignored even though is was on the pasteboard briefly |

### Bugs
See [Backlog.md](Backlog.md)

## Disclaimer
This is my first Swift project, I use VSCode, and love being in full control of my builds.
The code style may be very subjective. 🤓

## Contributions
If you know a better way to provide swift packages/apps without XCode, feel free to contribute!

Comments, bug reports, improvements are also welcome.
