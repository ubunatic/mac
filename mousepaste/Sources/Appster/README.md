# Appster: SwiftUI App Development Kit for MacOS

Appster is a small kit of classes and functions that help developing plain
SwiftUI Apps on MacOS. They help with some of the issues when not using XCode,
but developing directly in plain Swift, e.g., in VSCode and manually compiled via
`swift build` command.

## Features

### [Accessibility](Accessibility.swift)
* Request Accessibility to enabled (trusted access).
  ```swift
  AX.ensureTrustedAccess()
  ```
* Check if focussed element allows text input.
  ```swift
  AX.hasTextInputFocus()
  ```
* Send Cmd+C/V KeyPress.
  ```swift
  myKeyPresser.press(CmdKeyPresser.C)
  ```
* Get focussed UI element and selected text from focussed UI element. This will only work if the App supports Accessibility properties.

### [Go](Go.swift)
Adds a `go` function to run code async using the standard event queues.
  ```swift
  go {
    // code to run async
  }
  go(delayMs) {
    // code to run after delayMs Milliseconds
  }
  ```

### [Window Management](Windows.swift)
Experimental features to watch and control existing App windows.

### [Status Menus](StatusMenu.swift)
Rapid setup of App status menus.

```swift
    StatusMenu(
        appIcon,
        MenuItem("Start", action:start).keyboardShortcut("s"),
        MenuItem("Stop",  action:stop).keyboardShortcut("x"),
        MenuItem("Clear", action:clear).keyboardShortcut("c"),
        NSMenuItem.separator(),
        MenuItem("Preferences", action:settings, keyEquivalent: ","),
    )
```

### [App Management](Instace.swift)

