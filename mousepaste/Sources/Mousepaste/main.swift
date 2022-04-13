// Mousepaste Script
// =================
// Single-file script version of Mousepaste.
// This script is a smart concatenation of all Mousepaste swift files.
// It has no additional or less code and provides the same features as
// the regular app.
//
// Usage:
//    swift mousepaste.swift      # runs the code as script
//    ./mousepaste.swift          # runs the code as script via it's shebang
//    swiftc -O mousepaste.swift  # compile your own binary
//

import ApplicationServices
import Foundation
import AppKit
import Darwin

func main() {
    if !ensureTrustedAccess() {
        exit(EXIT_FAILURE)
    }

    backupPasteboard()
    Watcher.shared.watch()
    print("Starting Mousepaste mouse selection watcher as shared application")
    if DEBUG {
        print("detected DEBUG=\(DEBUG), running in debug mode")
    }
    NSApplication.shared.run()
}

// TODO: add some CLI args
// TODO: add a basic UI to quit the app

let PasteboardCopyDelay = 0.01
let DEBUG = (ProcessInfo.processInfo.environment["DEBUG"] ?? "") != ""

main()
