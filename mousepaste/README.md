# Mousepaste
<img  src="Icons/Mousepaste.svg" width="64" style="float:left"/>
MacOS system-wide capturing of mouse selections
to provide Linux-style middle-mouse pasting feature.
Implemented using VSCode in plain Swift without requiring XCode.

## Usage
```bash
# build and install
make app && sudo make install
# run it from the install location
/opt/mousepaste/Mousepaste.app/Contents/MacOS/Mousepaste -h
```
If you do not want to run the app from the install location
add it to your PATH.
```bash
export PATH="$PATH:/opt/mousepaste/Mousepaste.app/Contents/MacOS"

Mousepaste -h
```

### User Interface
By default the app provides a menu in the status bar.
Use `--nogui` to run it without the status bar UI.

## Why do I need this app?
1. Nothing is faster than automatically copying +
   pasting with the middle mouse button.
2. Once you are used to it, you can't live without.
3. Other tools that implement this on MacOS
   are not open-source and not small.
4. Do one thing and do it well.

## Requirements
* MacOS (obviously)
* Swift (unless you want to use a precompiled version)
* No XCode required!

Why no XCode? Because Swift has (nearly) all the tools you need,
and XCode easts up a ton of disk space.
Apple should not make it a requirement to build Swift packages.
This project just uses `make` and some simple scripts to manage
all Swift code without XCode.

## Development
To `swift build` this project without XCode, you must put a fake `xctest`
on your `PATH` (e.g., an empty shell script). This is unfortunately needed
since `swift` uses `xcrun` which then looks for `xctest` to run any package
tests (even when there are no test).

### Installing Swift
If you installed Apple's Command Line Tools you may have a recent Swift
version installed. If this does not work with your IDE of choice (e.g., no
cross-file code navigation in your package) then try  one of the following.
```
brew install swift
```
In VSCode, set the toolchain path of the Swift plugin to point to the installation, e.g., to the Homebrew installation:
* Swift > Path > `/opt/homebrew/opt/swift/bin`
* Swift > Toolchain Path > `/opt/homebrew/opt/swift/Swift-5.6.xctoolchain`

VSCode will complain if it cannot not start the language server.
Try to navigate from package code in one file to another, e.g., from the [App.swift](Sources/Mousepaste/App.swift) code to any of the referenced classes via `CMD+click`.

## Testing and Compatibility
See [Testing.md](Testing.md)

## How does it work?
See [Details.md](Details.md).

## Bugs
See [Backlog.md](Backlog.md).

## Disclaimer
This is my first Swift project, I use VSCode, and love being in full control of my builds.
The code style may be very subjective. 🤓

## Contributions
If you know how to teach the Electron apps to behave to the Accessibility API, I would love to see some code. 🙏

If you know a better way to provide Swift packages/apps without XCode, feel free to contribute!

Comments, bug reports, improvements are also welcome.
