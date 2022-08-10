// Instance package implements checking for multiple instances of an app.
// Checks are based on the bundle ID and executable URL and require
// access to NSRunningApplication and NSWorkspace.

import os
import SwiftUI
import Logging

public class AppInstanceState: NSObject {
    // static instance for managing singletion Apps
    static let shared = AppInstanceState()

    // the App instance owing this state
    var instance:Any?

    // stored statusIcon
    // TODO: check if this storage is still needed in swift UI and the new state management
    public var statusIcon:NSStatusItem?
}

// AppInstance protocol requires adding a non-nil `appInstance:Self` to the App.
// This static property is used by the AppInstance extension to manage the single-instance
// lifecycle of an `App`.
public protocol AppInstance: App {
    // single instance of the App
    // static var appInstance:Self? { get set }

    // state of the App to manage status bar item and single instance
    var state:AppInstanceState { get set }

    // MacOS status bar menu
    var statusMenu:StatusMenu? { get }

    // app icon used in the status bar and dock
    var appIcon: NSImage { get }
}

// AppInstance extension provides initalizers and accessors
// for NSApplication and NSWindow management.
extension AppInstance {
    // app returns the shared NSApplication
    public var app:NSApplication { NSApplication.shared }

    // SystemStatusBar gives access to the system status bar
    public var SystemStatusBar:NSStatusBar { NSStatusBar.system }

    // statusIcon stores the system status bar icon (inialized on first access)
    private var statusIcon:NSStatusItem {
        if state.statusIcon == nil {
            state.statusIcon = SystemStatusBar.statusItem(withLength: NSStatusItem.variableLength)
        }
        return state.statusIcon!
    }

    // makeSingleInstance makes the current app instance the only one, killing any others.
    // TODO: implement killing of other instances.
    public func makeSingleInstance() {
        warn("makeSingleInstance not implemented (other apps may still be running)")
        AppInstanceState.shared.instance = self
    }

    // requireSingleInstance exits tha current program if other instances are found.
    public func requireSingleInstance() {
        if !isSingleInstance() {
            fatal("app:\(type(of: self)) is not the single instance, please quit all other instances first")
        }
        makeSingleInstance()
    }

    public func showPreferences() {
        app.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }

    public func showPreferencesAndActivate() {
        showPreferences()
        app.activate(ignoringOtherApps: true)
    }

    // initApp runs all post-init code that needs to be run asynchronously after
    // App.init finished. This is needed for some UI setup procedures that would
    // fail if called inside App.init.
    public func initApp(done: @escaping () -> ()) {
        go {
            addStatusMenu()
            done()
        }
    }

    public func addStatusMenu(_ title:String="") {
        guard let statusMenu = statusMenu else {
            return
        }

        if statusMenu.icon != nil {
            statusIcon.button?.image = statusMenu.icon
        }
        if title != "" {
            statusIcon.button?.title = title
        }
        if statusMenu.icon == nil && title == "" {
            // no image or title set, fallback to using the gears icon
            // so the status item is not empty
            statusIcon.button?.title = "⚙️"
        }

        // attach menu
        statusIcon.menu = statusMenu
    }
}

// isSingleInstance returns whether or not the current apps instance count
// is bigger than `maxCount`.
// If called from your main (e.g., in CLI mode), use maxCount = 0 (default).
// If called after applicationDidFinishLaunching, use maxCount = 1.
// This function is app-agnostic.
public func isSingleInstance(maxCount:Int = 0) -> Bool {
    debug("Instance.isSingleInstance")
    debugValue("Bundle.main.bundleIdentifier", Bundle.main.bundleIdentifier)
    debugValue("Bundle.main.executableURL", Bundle.main.executableURL)
    if Bundle.main.bundleIdentifier != nil {
        // find apps with same bundleIdentifier
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!)
        debugValue("others.count", others.count)
        if others.count > maxCount {
            return false
        }
    }

    // find apps with same executable
    let apps = NSWorkspace.shared.runningApplications.filter { app in
        return app.executableURL == Bundle.main.executableURL
    }
    debugValue("apps.count", apps.count)
    if apps.count > maxCount {
        return false
    }

    // app is probably a single instance. 🤞
    return true
}

// ensureSingleInstance calls the `failure` function
// if the single instance check fails.
func ensureSingleInstance(failure: () -> ()) {
    if !isSingleInstance() { failure() }
}
