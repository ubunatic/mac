# Mousepaste Internals
This document summarizes how Mousepaste works and lists a few potential issues.
Also see [Backlog.md](Backlog.md) for more technical details.

## How does it work?
Mousepaste currently detects a few common gestures that indicate (but not guarantee) that a text selection happened. See [Watcher.swift](Sources/Mousepaste/Watcher.swift) for details. Mousepaste then tries to access and copy the selection using the MacOS Accessibility API. If this fails or yields and empty selection, Mousepaste issues a `CMD+C` as fallback and tries to anticipate any side-effect that this may incurr.

### Why simulate keypresses?

The `CMD+C` hack is needed, since not all commonly used apps support the Accessibility API ([VSCode]() and other [Electron](https://www.electronjs.org/) apps).

### System Preferences
Mousepaste is supposed to work system-wide and for all apps. For this is needs the *Accessibility* rights from the *System Preferences* > *Security & Privacy*. You should see a popup during first-time startup to request this access.

### Edge Cases
Beyond the basic flow described above, Mousepaste needs tweaking on all ends to work reliably. For instance, a selection needs to be copied in time, before another text is selected, but for the `CMD+C` path also not too early. Things that should not be copied must be ignored. Non-textual Pasteboard items must be correctly restored, when misusing the Pasteboard via `CMD+C`. And so on. For more funny edge cases see [Backlog.md](Backlog.md).