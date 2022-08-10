// StatusApp package collects utilities for managing status-bar apps.

import SwiftUI
import Logging

public extension NSWindow {
    func makeReusable() {
        self.isMovableByWindowBackground = true
        self.hidesOnDeactivate = true
        self.isReleasedWhenClosed = false
        self.tabbingMode = .disallowed
        self.sharingType = .readWrite
        self.styleMask = [.closable, .titled, .unifiedTitleAndToolbar]
    }
}

public enum WindowFilter {
    case Main, Key, Title, NoTitle, Visible, AppWindow
}

public func awaitWindow(
    _ timeoutMS: Double = 100, _ numTries: Int = 100,
    filter:WindowFilter = .AppWindow,
    app:NSApplication = NSApplication.shared,
    found: @escaping (NSWindow) -> ()
) {
        if numTries <= 0 {
            error("failed to open window in time")
            return
        }
        let w = app.windows.first() { w in
            switch filter {
                case .Main:    return w.isMainWindow
                case .Key:     return w.isKeyWindow
                case .Visible: return w.isVisible
                case .AppWindow: return w.isRestorable
                case .Title:   return w.title != ""
                case .NoTitle: return w.title == ""
            }
        }
        guard let w = w else {
            go(timeoutMS) { awaitWindow(timeoutMS, numTries - 1, found: found) }
            return
        }
        debug("awaitWindow: found window \(w.title) \(w.frame.size)")
        found(w)
}

public struct WindowAccessor: NSViewRepresentable {
    let title: String
    @State public var window:NSWindow?

    public init(_ title:String="") {
        self.title = title
    }

    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        if view.window != nil {
            window = view.window
        }
        go {
            if window != nil {
                debug("resuing existing window:\(window!.title)")
                return
            }
            guard let w = view.window else {
                error("cannot use nil as window:\(title) from view \(view)")
                return
            }
            debug("creating view with window \(w) (\(w.title))")
            if self.window != w {
                // debug("closing old window \(self.window?.title ?? "(nil)") and setting up new window:\(w.title)")
                // self.window?.close()
                self.window = w
            }
            if title != "" {
                // debug("rename view window from: '\(w.title)' to: '\(title)'")
                // w.title = title
            }
        }
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {}
}
