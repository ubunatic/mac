import SwiftUI
import ArgumentParser
import Appster
import Logging
import os

@main
struct MousepasteApp: AppInstance {
    var state: AppInstanceState = AppInstanceState()
    let args = MousepasteCli.parseOrExit()
    let watcher = Watcher()

    // @Environment(\.scenePhase) var scenePhase

    init() {
        args.run()
        MousepasteCli.inputLoop.onKeyPress("q") { MousepasteCli.exit(OK, "q -> exit") }
        MousepasteCli.inputLoop.onKeyPress("w", settings)
        MousepasteCli.inputLoop.onKeyPress("d", { AX.debugApp() })
        MousepasteCli.inputLoop.onKeyPress("s", { MousepasteCli.inputLoop.stop() })
        MousepasteCli.inputLoop.start()
        requireSingleInstance()
        app.setActivationPolicy(.accessory)
        self.initApp(done: start)
    }

    func start()    { watcher.start() }
    func stop()     { watcher.stop()  }
    func clear()    { clearPasteboard() }
    func settings() { showPreferencesAndActivate() }
    func quit()     { MousepasteCli.exit(OK, "App.quit") }

    var appIcon: NSImage { Images.AppIcon }

    var statusMenu: StatusMenu? {
        StatusMenu(
            appIcon,
            MenuItem("Start Watcher",   action:start).keyboardShortcut("s"),
            MenuItem("Stop Watcher",    action:stop).keyboardShortcut("x"),
            MenuItem("Clear Selection", action:clear).keyboardShortcut("c"),
            NSMenuItem.separator(),
            MenuItem("Preferences",     action:settings, keyEquivalent: ","),
            MenuItem("Debug",           action: { AX.debugApp(app) }).keyboardShortcut("d").visible(LogConfig.debug),
            MenuItem("Quit",            action:quit).keyboardShortcut("q", .command)
        )
    }

    var body: some Scene {
        Settings {
            SettingsView()
        }
        .commands {
            // TODO: add Quit
        }
    }
}
