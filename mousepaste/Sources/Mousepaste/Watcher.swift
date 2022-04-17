// Watcher package implements a mouse event monitor
// for captruring selection actions done with the mouse.

import ApplicationServices
import Foundation
import AppKit

typealias Mask = NSEvent.EventTypeMask
typealias Type = NSEvent.EventType

class Watcher: Service {
    var dragging = false
    var selection = ""
    var observer:Any?

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

    func stop() {
        if observer != nil {
            NSEvent.removeMonitor(observer!)
            if config.debug { print("removed observer: \(observer.debugDescription)") }
            print("Stopped mouse selection watcher")
            observer = nil
        }
    }

    func start() {
        if observer != nil {
            return
        }
        observer = NSEvent.addGlobalMonitorForEvents(
            matching: self.selectionMask,
            handler: self.handleEvent
        )
        if config.debug { print("added observer: \(observer.debugDescription)") }
        print("Starting mouse selection watcher")
    }

    var isActive: Bool {
        get { return observer != nil }
    }

    let selectionMask:Mask = [
        Mask.leftMouseDown, Mask.leftMouseUp,
        Mask.otherMouseDown, Mask.otherMouseUp,
        Mask.leftMouseDragged
    ]

    static let shared = Watcher()
}
