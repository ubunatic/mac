# Mousepaste
MacOS system-wide capturing of mouse-selection
to provide Linux-style middle-mouse pasting feature.

## Usage
Copy [script/mousepaste.swift](script/mousepaste.swift) anywhere you want and run it.
```bash
./mousepaste.swift
```

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
* **No XCode required!**

Why no XCode? Because `swift` has (nearly) all the tools you need,
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

## Testing
To test your changes, just `DEBUG=1 make run` the app and test it.
Make sure it works in some native Apps, in Chromium-based browsers, and in Electron Apps.

### Tested Apps
| App + Type    | Selection Type |
| ------------- | -------------- |
| Script Editor | AX             |
| Brave         | AX             |
| Slack         | AX             |
| KeepassXC     | AX             |
| iTerm2        | AX             |
| Terminal      | AX             |
| Finder        | AX             |
| Notes         | AX             |
| Safari        | `Cmd+C`        |
| VSCode        | `Cmd+C`        |
| Electron Apps | `Cmd+C`        |

## Contributions
If you know a better way to provide swift packages/apps without XCode, feel free to contribute!

Comments, bug reports, improvements are also welcome.
