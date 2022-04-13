#!/usr/bin/env swift -O
// ----------------------------
// GENERATED CODE, DO NOT EDIT!
// ----------------------------
//
// This file is a concatenation of the following sources:

// * Sources/Mousepaste/main.swift
// * Sources/Mousepaste/Accessibility.swift
// * Sources/Mousepaste/Pasteboard.swift
// * Sources/Mousepaste/Watcher.swift
// * Sources/Mousepaste/Selection.swift

// START merged imports
import AppKit
import ApplicationServices
import Darwin
import Foundation
// END merged imports

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/main.swift
//

// Mousepaste Script
// =================
// Single-file script version of Mousepaste.
// This script is a smart concatenation of all Mousepaste swift files.
// It has no additional or less code and provides the same features as
// the regular app.
//
// Usage:
//    swift mousepaste.swift      # runs the code as script
//    ./mousepaste.swift          # runs the code as script via it's shebang
//    swiftc -O mousepaste.swift  # compile your own binary
//


func main() {
    if !ensureTrustedAccess() {
        exit(EXIT_FAILURE)
    }

    backupPasteboard()
    Watcher.shared.watch()
    print("Starting Mousepaste mouse selection watcher as shared application")
    if DEBUG {
        print("detected DEBUG=\(DEBUG), running in debug mode")
    }
    NSApplication.shared.run()
}

// TODO: add some CLI args
// TODO: add a basic UI to quit the app

let PasteboardCopyDelay = 0.01
let DEBUG = (ProcessInfo.processInfo.environment["DEBUG"] ?? "") != ""

//
// END file: Sources/Mousepaste/main.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Accessibility.swift
//


// ensureTrustedAccess returns whether or not Accessibility is enabled.
func ensureTrustedAccess() -> Bool {
    let ok = AXIsProcessTrustedWithOptions(
        [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)

    if ok {
        print("Accessibility preferences enabled")
    } else {
        print("ERROR: Accessibility preferences not enabled")
    }

    return ok
}

let kFocused = kAXFocusedUIElementAttribute as CFString
let kSelected = kAXSelectedTextAttribute as CFString

func hasTextInputFocus() -> Bool {
    // First Try: Total failure using accessibility attributes!
    //
    // return isTextInput(getFocusedElement())
    //
    // AXUI properties will not work in many apps. We need something else
    // to know which type of UI is under the cursor and if it supports text input.

    // Second Try: Think like a human!
    // How do you as a human know that your mouse is hovering a text field?
    // Yes! The mouse cursor will tell you; even in a terminal.
    //
    // Awesome, let's hack the system cursor!
    //
    // We just need to check if the system cursor is the "iBeam" cursor.
    guard let cursor = NSCursor.currentSystem else { return false }
    let iBeam = NSCursor.iBeam
    //
    // But comparing two plain objects wont work. We need something more robust.
    // Fortunately we can access the cursor image and its bytes as an invariant.
    let cursorImage = cursor.image.tiffRepresentation
    let iBeamImage = iBeam.image.tiffRepresentation
    // Awesome, bytes can be easily compared! Done.
    return cursorImage == iBeamImage

    // TODO: Is there a better option to learn about potential text-input UI
    //       located under the cursor?
}

func isTextInput(_ elem:AXUIElement?) -> Bool {
    if elem == nil {
        return false
    }


    // This type check was useless: In VSCode all UI elements had the same type!
    let type = CFGetTypeID(elem)
    switch type {
    default:
        if DEBUG {
            print("CFTypeID: \(type)")
        }
    }

    return false
}

func getElementTypeUnderCursor() {
    // TODO: try other focussed UI elements and not only kAXFocusedUIElementAttribute
}

// getFocusedElement returns the currently focused AXUIElement.
func getFocusedElement() -> AXUIElement? {
    var focused: AnyObject?
    let err = AXUIElementCopyAttributeValue(AXUIElementCreateSystemWide(), kFocused, &focused)
    if err != .success || CFGetTypeID(focused) != AXUIElementGetTypeID() {
        return nil
    }
    let elem = focused as! AXUIElement
    return elem
}

// getFocusedSelection returns the selected text of the currently focused AXUIElement.
//
// Accessibility will usually be able to copy kAX* attributes,
// even if the app does not support them. In this case the value is empty.
// As a result, we cannot distinguish between empty and nil.
func getFocusedSelection() -> String {
    guard let elem = getFocusedElement() else { return "" }

    var any: AnyObject?
    let err = AXUIElementCopyAttributeValue(elem, kSelected, &any)
    if err != .success || any == nil {
        return ""
    }
    let val = any as! String

    // if val != nil --> provider is AX
    //
    // TODO: Add more AX checks if the UI Element is a text field.
    //       For instance if quickly clicking in in Finder,
    //       the selected file name will be considered.

    return val
}

class CmdKeyPresser {
    static let Cmd = CGEventFlags.maskCommand
    static let C: UInt16 = 0x08
    static let V: UInt16 = 0x09

    func press(_ key:UInt16) {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true) else { return }
        down.flags = CmdKeyPresser.Cmd
        down.post(tap: CGEventTapLocation.cghidEventTap)
        guard let up = CGEvent(keyboardEventSource: CGEventSource(event: down), virtualKey: key, keyDown: false) else { return }
        up.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
//
// END file: Sources/Mousepaste/Accessibility.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Pasteboard.swift
//

// Pasteboard package implements basic Pasteboard access.
// It is used by Watcher package to use the Pasteboard as
// buffer to access non-reachable text, i.e., selectedText
// that is not exposed via AXUI attributes.


let cmdKeyPresser = CmdKeyPresser()
var backupValue = ""
var backupHistory = "<empty>"

func sendCopyCommand() {
    cmdKeyPresser.press(CmdKeyPresser.C)
}

func sendPasteCommand() {
    cmdKeyPresser.press(CmdKeyPresser.V)
}

func readPasteboard() -> String {
    guard let val = NSPasteboard.general.string(forType: .string) else {
        return ""
    }
    return val
}

func writePasteboard(_ val:String) {
	if val == "" {
		return
	}
    clearAndWritePasteboard(val)
}

func clearPasteboard() {
    NSPasteboard.general.clearContents()
}

func clearAndWritePasteboard(_ val:String) {
    NSPasteboard.general.clearContents()
	NSPasteboard.general.setString(val, forType: .string)
}

func backupPasteboard() {
    let val = readPasteboard()
    if val != backupValue {
        backupValue = val
        if DEBUG {
            backupHistory += " | " + backupValue
            print(backupHistory)
        }
    }
}

func restorePasteboard() {
    clearAndWritePasteboard(backupValue)
}
//
// END file: Sources/Mousepaste/Pasteboard.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Watcher.swift
//

// Watcher package implements a mouse event monitor
// for captruring selection actions done with the mouse.


typealias Mask = NSEvent.EventTypeMask
typealias Type = NSEvent.EventType

class Watcher {
    var watching = false
    var dragging = false
    var selection = ""

    init() {}

    func handleEvent(e: NSEvent) -> Void {
        let isLeftUp = e.type == Type.leftMouseUp
        let isOtherUp = e.type == Type.otherMouseUp
        let isDrag = e.type == Type.leftMouseDragged
        let isShiftDown = e.modifierFlags.contains(NSEvent.ModifierFlags.shift)
        if isDrag {
            dragging = true
            return
        }

        let count = e.clickCount
        var event:SelectionEvent? = nil
        if isLeftUp && count > 1 {
            event = SelectionEvent(.Copy, "multi click: copy")
        } else if isLeftUp && dragging {
			event = SelectionEvent(.Copy, "drag end: copy")
        } else if isLeftUp && isShiftDown {
			event = SelectionEvent(.Copy, "shift click: copy")
        } else if isOtherUp {
		    event = SelectionEvent(.Paste, "other up: paste")
        }

        dragging = false
        event?.execute()
    }

    func watch() {
        if watching {
            return
        }

        watching = true
        NSEvent.addGlobalMonitorForEvents(
            matching: self.selectionMask,
            handler: self.handleEvent
        )
    }

    let selectionMask:Mask = [
        Mask.leftMouseDown, Mask.leftMouseUp,
        Mask.otherMouseDown, Mask.otherMouseUp,
        Mask.leftMouseDragged
    ]

    static let shared = Watcher()
}
//
// END file: Sources/Mousepaste/Watcher.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Selection.swift
//


class SelectionEvent {
    enum EventType:Int {
        case Copy, Paste
    }

    enum SelectionProvider {
        case None, AX, KeyPress
    }

    var type:EventType
    var description:String

    var backup = ""
    var selected = ""
    var restored = ""
    var provider = SelectionProvider.None

    static var sharedText = ""

    // A serialQueue allows serializing function calls to
    // avoid data races from concurrent events.
    static let serialQueue = DispatchQueue(label: "SelectionEvent.serialQueue")

    init(_ type:EventType, _ description:String) {
        self.type = type
        self.description = description
    }

    // execute processes the selection event serialized with other selection events.
    func execute() {
        SelectionEvent.serialQueue.sync {
            unsafeExecute()
        }
    }

    // unsafeExecute processes the selection event immediately.
    private func unsafeExecute()  {
        backup = readPasteboard()
        switch type {
        case .Copy:
            (selected, provider) = GetSelection()
            if selected != "" {
                SelectionEvent.sharedText = selected
            }
        case .Paste:
            if hasTextInputFocus() {
                PasteSelection(SelectionEvent.sharedText)
            }
        }
        restored = readPasteboard()
        if DEBUG {
            print(describe())
        }
    }

    func describe() -> String {
        return ("SelectionEvent(" +
            "backup:\(backup), " +
            "selected:\(selected), " +
            "restored:\(restored), " +
            "provider:\(provider))"
        )
    }
}

func GetSelection() -> (String, SelectionEvent.SelectionProvider) {
    let val = getFocusedSelection()
    if val != "" {
        return (val, .AX)
    }
    return (CopySelectionFromPasteboard(), .KeyPress)
}

func CopySelectionFromPasteboard() -> String {
    backupPasteboard()
    defer { restorePasteboard() }

    // Must clear pasteboard to allow reading empty selection!
    // VSCode for instance will not copy anyting on Cmd+C unless
    // "editor.emptySelectionClipboard" is true.
    // If not cleared, readPasteboard will later read anything that is left on
    // the pasteboard instead of the selected (empty) text.
    clearPasteboard()

    // TODO: a) find alternative to detect empty selection
    // TODO: b) determine if Cmd+C had any effect
    // TODO: c) determine if Cmd+C will have any effect before even sending the keypress
    sendCopyCommand()
    Thread.sleep(forTimeInterval: PasteboardCopyDelay)
    return readPasteboard()
}

func PasteSelection(_ val:String) {
    backupPasteboard()
    defer { restorePasteboard() }

    writePasteboard(val)
    sendPasteCommand()
    Thread.sleep(forTimeInterval: PasteboardCopyDelay)
}
//
// END file: Sources/Mousepaste/Selection.swift
//


// START main
main()
// END main

