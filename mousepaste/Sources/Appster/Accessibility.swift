// This accessibility package implements key pressing, detection of selected
// UI elements and detection of selected text. It relies on the system's
// accessibility API. The host app must be added to trusted applications in
// Security > Privacy > Accessibility.

import SwiftUI
import Logging

public struct AX {
    static let kTrusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
    static let kTrustedOptions = [kTrusted:true] as CFDictionary
    static let kFocused = kAXFocusedUIElementAttribute as CFString
    static let kSelected = kAXSelectedTextAttribute as CFString

    // ensureTrustedAccess returns whether or not Accessibility is enabled.
    public static func ensureTrustedAccess() -> Bool {
        debug("Mousepaste:Accessibility:ensureTrustedAccess")
        let trusted = AXIsProcessTrustedWithOptions(kTrustedOptions)
        if trusted {
            print("Accessibility preferences enabled")
        } else {
            print("ERROR: Accessibility preferences not enabled")
        }
        return trusted
    }

    public static func hasTextInputFocus() -> Bool {
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
        // But comparing two plain objects won't work. We need something more robust.
        // Fortunately we can access the cursor image and its bytes as an invariant.
        let cursorImage = cursor.image.tiffRepresentation
        let iBeamImage = iBeam.image.tiffRepresentation
        // Awesome, bytes can be easily compared! Done.
        return cursorImage == iBeamImage

        // TODO: Is there a better option to learn about potential text-input UI
        //       located under the cursor?
    }

    // isTextInput returns whether or not the given AXUIElement is a text input.
    // This is determined using a type check and will not work in all apps.
    public static func isTextInput(_ elem:AXUIElement?) -> Bool {
        if elem == nil {
            return false
        }

        // This type check was useless: In VSCode all UI elements had the same type!
        // TODO: Are there better ways to check UI types that work well in Electron apps?
        let type = CFGetTypeID(elem)
        switch type {
        default:
            if LogConfig.debug { debug("CFTypeID: \(type)") }
        }

        return false
    }

    static func getElementTypeUnderCursor() {
        // TODO: try other focussed UI elements and not only kAXFocusedUIElementAttribute
    }

    // getFocusedElement returns the currently focused AXUIElement.
    public static func getFocusedElement() -> AXUIElement? {
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
    public static func getFocusedSelection() -> String {
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
        //       For instance if quickly clicking in Finder,
        //       the selected file name will be considered.

        return val
    }

    // debugApp DEBUG-logs all kinds of UI-related properties of an app.
    public static func debugApp(_ app:NSApplication=NSApplication.shared) {
        // let windowNames = app.windows.map { w in w.title }
        let windowsStatus = "\n" + app.windows.map { w in
            w.backgroundColor =
                w.title == "" ? .systemRed :
                w.title.contains("Item") ? .green :
                w.title.contains("Mouse") ? .systemPink :
                w.title.contains("Delegate") ? .systemPurple :
                .systemYellow
            var title = w.title
            if title == "" {
                title = "Unnamed"
            }
            let cls = type(of: w)
            let desc = " \(cls): \"\(title )\","
                     + " key=\(w.isKeyWindow) main=\(w.isMainWindow)"
                     + " res=\(w.isRestorable) vis=\(w.isVisible)"
                     + " mod=\(w.isModalPanel) ex=\(w.isExcludedFromWindowsMenu)"
                     + " w=\(w.frame.width) h=\(w.frame.height)\n"
                     + " -----------------"
            if w.frame.width == 0 {
                debug(desc)
                debug(w)
                debugValue("w.isFloatingPanel", w.isFloatingPanel)
                debugValue("w.isExcludedFromWindowsMenu", w.isExcludedFromWindowsMenu)
                debugValue("w.isMainWindow", w.isMainWindow)
                debugValue("w.isMiniaturized", w.isMiniaturized)
                debugValue("w.isModalPanel", w.isModalPanel)
                debugValue("w.isRestorable", w.isRestorable)
                debugValue("w.isVisible", w.isVisible)
            }
            return desc
        }.joined(separator: "\n")
        debugValue("app.windows.count", app.windows.count)
        debugValue("app.windows", windowsStatus)
        // debugValue("app.delegate", app.delegate)
        // debugValue("app.delegate.superclass", app.delegate?.superclass)
        // debugValue("appdelegate.applicationShouldHandleReopen.publisher",
        //            app.delegate?.applicationShouldHandleReopen.publisher)
    }
}

// CmdKeyPresser is a simple class to trigger CMD+key presses.
public class CmdKeyPresser {
    public static let Cmd = CGEventFlags.maskCommand
    public static let C: UInt16 = 0x08
    public static let V: UInt16 = 0x09

    public init(){}

    public func press(_ key:UInt16) {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true) else { return }
        down.flags = CmdKeyPresser.Cmd
        down.post(tap: CGEventTapLocation.cghidEventTap)
        guard let up = CGEvent(keyboardEventSource: CGEventSource(event: down), virtualKey: key, keyDown: false) else { return }
        up.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
