# Mousepaste.fyne
This is an alternative app to the Swift-based [Mousepaste.app](../Sources/Mousepaste).
Fyne looks quite mature and supports sys-tray icons and more. But is it suitable for
MacOS system-level app development?

For Mousepaste we would at least need the foillowing features.

## Required Features

* Select text using Accessibility API in currently focussed app
* Open system prefs and request Accessibility rights
* Send Cmd+C/V
* Read/Write/Restore Pasteboard for the content types `html`, `text`, `tiff` at least
