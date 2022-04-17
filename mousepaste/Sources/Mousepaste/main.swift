import ApplicationServices
import Foundation
import AppKit
import Darwin

func runApp() {
    debug("Mousepaste:runApp")
    if !isSingleInstance() {
        print("Mousepaste is already running")
        return
    }

    if !ensureTrustedAccess() {
        exit(EXIT_FAILURE)
    }

    backupPasteboard()

    let app = NSApplication.shared
    if config.showGui {
        app.setActivationPolicy(.accessory)
        let delegate = AppDelegate(app, Watcher.shared)
        app.delegate = delegate
        info("Starting Mousepaste with GUI")
    } else {
        info("Starting Mousepaste without GUI")
        Watcher.shared.start()
    }
    app.run()

    print("Mousepaste stopped")
}


func main() {
    config = parseArgs()
    runApp()
}

main()
