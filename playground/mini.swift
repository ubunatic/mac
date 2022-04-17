import AppKit

class App : NSObject, NSApplicationDelegate {
    let app = NSApplication.shared
    let name = ProcessInfo.processInfo.processName
    let status = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let window = NSWindow.init(
        contentRect: NSMakeRect(0, 0, 200, 200),
        styleMask: [.titled, .closable, .miniaturizable],
        backing: .buffered,
        defer: false
    )

    override init() {
        super.init()
        app.setActivationPolicy(.accessory)

        window.center()
        window.title = name
        window.hidesOnDeactivate = false
        window.isReleasedWhenClosed = false

        let statusMenu = newMenu()
        status.button?.title = "🤓"
        status.menu = statusMenu

        let appMenu = newMenu()
        let sub = NSMenuItem()
        sub.submenu = appMenu
        app.mainMenu = NSMenu()
        app.mainMenu?.addItem(sub)
    }

    @IBAction func activate(_ sender:Any?) {
        app.setActivationPolicy(.regular)
        DispatchQueue.main.async { self.window.orderFrontRegardless() }
    }

    @IBAction func deactivate(_ sender:Any?) {
        app.setActivationPolicy(.accessory)
        DispatchQueue.main.async { self.window.orderOut(self) }
    }

    private func newMenu(title: String = "Menu") -> NSMenu {
        let menu = NSMenu(title: title)
        let q = NSMenuItem.init(title: "Quit",  action: #selector(app.terminate(_:)), keyEquivalent: "q")
        let w = NSMenuItem.init(title: "Close", action: #selector(deactivate(_:)),    keyEquivalent: "w")
        let o = NSMenuItem.init(title: "Open",  action: #selector(activate(_:)),      keyEquivalent: "o")
        for item in [o,w,q] { menu.addItem(item) }
        return menu
    }

    func applicationDidFinishLaunching(_ n: Notification) { }

    func applicationDidHide(_ n: Notification) {
        app.setActivationPolicy(.accessory)
        DispatchQueue.main.async { self.window.orderOut(self) }
    }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.run()
