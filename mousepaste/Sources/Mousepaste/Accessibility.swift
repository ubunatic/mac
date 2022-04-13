import Foundation
import ApplicationServices
import AppKit

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
