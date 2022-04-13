// Watcher package implements a mouse event monitor
// for captruring selection actions done with the mouse.

import ApplicationServices
import Foundation
import AppKit

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
