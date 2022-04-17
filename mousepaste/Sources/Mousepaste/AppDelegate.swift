import ApplicationServices
import Foundation
import AppKit

typealias Func = () -> Void

struct Icon {
    static let Mousepaste = "🐭"
    static let Door = "🚪"
    static let Play = "▶️"
    static let Stop = "⏹"
    static let Quit = "❌"
    static let Broom = "🧹"
    static let Paste = "📋"
    static let Empty = "∅"
    static let Bug = "🪲"
    static let Gear = "⚙️"
}

class AppDelegate: NSObject, NSApplicationDelegate, Service {
    let name:String
    let window = NSWindow.init(
        contentRect: NSMakeRect(0, 0, 200, 200),
        styleMask: [.titled, .closable, .miniaturizable],
        backing: .buffered,
        defer: false
    )

    let popover   = NSPopover.init()
    let itemStart = NSMenuItem.init()
    let itemStop  = NSMenuItem.init()
	let itemQuit  = NSMenuItem.init()
    let itemDebug = NSMenuItem.init()
    let itemPrefs = NSMenuItem.init()
    let status    = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    let app:NSApplication
    let watcher:Service
    var isActive:Bool { get { return watcher.isActive } }

    init(_ app: NSApplication, _ watcher: Service) {
        self.app = app
        self.watcher = watcher

        if ProcessInfo.processInfo.processName.lowercased().contains("mousepaste") {
            name = ProcessInfo.processInfo.processName
        } else {
            name = "Mousepaste"
            ProcessInfo.processInfo.processName = name
        }

        app.setActivationPolicy(.accessory)

        window.center()
        window.title = name
        window.hidesOnDeactivate = false
        window.isReleasedWhenClosed = false

        let root = NSMenu(title: "Mousepaste")
        app.mainMenu = root
        let rootItem = NSMenuItem()
        let menu = NSMenu(title: "Main")
        let item = NSMenuItem(
            title: "Quit",
            action: #selector(self.quit(_:)),
            keyEquivalent: "q"
        )
        app.mainMenu?.addItem(rootItem)
        rootItem.submenu = menu
        menu.addItem(item)
        super.init()
    }

    @IBAction func activate(_ sender:Any?) {
        debug("activate")
        app.setActivationPolicy(.regular)
        DispatchQueue.main.async { self.window.orderFrontRegardless() }
    }

    @IBAction func deactivate(_ sender:Any?) {
        debug("deactivate")
        app.setActivationPolicy(.accessory)
        DispatchQueue.main.async { self.window.orderOut(self) }
    }

    func applicationDidHide(_ notification: Notification) {
        trace("Mousepaste:AppDelegate.applicationDidHide")
        app.setActivationPolicy(.accessory)
        DispatchQueue.main.async {
            self.window.orderOut(self)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        trace("Mousepaste:AppDelegate.applicationShouldHandleReopen")
        activate(self)
        return false
    }

    // TODO: find a modern + low-code way of adding action handlers
    @IBAction func prefs(_ sender:Any?) { activate(sender) }
    @IBAction func quit(_  sender:Any?) { app.stop(sender) }
    @IBAction func toggleDebug(_  sender:Any?) {
        config.logLevel = config.debug ? .info : .debug
        info("setting log level to \(config.logLevel) (debug = \(config.debug))")
    }

    func start() { watcher.start(); update() }
    func stop()  { watcher.stop(); update() }

    func update() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            debug("isActive = \(self.isActive)")
            if self.isActive {
                // The best way to control enabled/diabled state of the menu is to add/remove actions.
                // Manually setting isEnabled will not persist.
                self.itemStart.action = nil
                self.itemStop.action = #selector(self.stop)
            } else {
                self.itemStart.action = #selector(self.start)
                self.itemStop.action = nil
            }
        })
    }

    func applicationDidUpdate(_ notification: Notification) {
        trace("Mousepaste:AppDelegate.applicationDidUpdate")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        trace("Mousepaste:AppDelegate.applicationDidFinishLaunching")

		status.button?.title = Icon.Mousepaste
        status.menu = NSMenu()

        func addItem(_ m:NSMenuItem, _ icon:String, _ title:String,
            key:String="", flags:NSEvent.ModifierFlags = NSEvent.ModifierFlags(), action:Selector? = nil) {
                m.title = icon != "" ? "\(icon) \(title)" : title
                m.action = action
                m.keyEquivalent = key
                m.keyEquivalentModifierMask = flags
                status.menu?.addItem(m)
        }

		addItem(itemStart, Icon.Play, "Start", key: "s")
   		addItem(itemStop,  Icon.Stop, "Stop",  key: "x")
		addItem(itemDebug, Icon.Bug,  "Debug", key: "#", action: #selector(self.toggleDebug(_:)))
		addItem(itemQuit,  Icon.Door, "Quit",  key: "q", action: #selector(self.quit(_:)))
        addItem(itemPrefs, Icon.Gear, "Settings",  key: ",", flags: NSEvent.ModifierFlags.command, action: #selector(self.prefs(_:)))

        // TODO: allow Watcher auto start via settings
        start()

        if config.debug { activate(self) }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        stop()
    }
}
