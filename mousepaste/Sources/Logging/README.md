# Logging

Simple string based logging with support for various log levels.

## Usage

```swift

import Logging

debug("message")
debugValue("Var.debug.identifier", anyValue)
printValue("Var.info.identifier", anyValue)

func customizerLogger() {
    LogConfig.log = { print("customized", $0) }
}

func testLevels() {
    if LogConfig.debug { ... }
    if LogConfig.level > .error { ... }
    // etc.
}

```