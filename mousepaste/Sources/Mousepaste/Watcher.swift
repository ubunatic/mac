// Watcher package implements a mouse event monitor
// for captruring selection actions done with the mouse.

import Foundation
import SwiftUI
import Logging

class Watcher: Service {
    var dragging = false
    var selection = ""
    var observer:Any?

    func handleEvent(e: NSEvent) -> Void {
        // TODO: Consider breaking early on events that need not be handled.
        //       This would probably mean moving some UI detection logic here. 🤔
        //       But maybe there is a smarter way to detect non-text selection events;
        //       esp. in Games where you may be dragging the mouse a lot and also
        //       shift clicks are very common.

        let isLeftUp = e.type == .leftMouseUp
        let isOtherUp = e.type == .otherMouseUp
        let isDrag = e.type == .leftMouseDragged
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
            if LogConfig.debug { print("removed observer: \(observer.debugDescription)") }
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
        if LogConfig.debug { print("added observer: \(observer.debugDescription)") }
        print("Starting mouse selection watcher")
    }

    var isActive: Bool {
        get { return observer != nil }
    }

    let selectionMask:NSEvent.EventTypeMask = [
        .leftMouseDown, .leftMouseUp,
        .otherMouseDown, .otherMouseUp,
        .leftMouseDragged
    ]

    static let shared = Watcher()
}
