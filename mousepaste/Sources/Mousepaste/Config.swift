
import Darwin
import Foundation
import ApplicationServices
import os

struct MousepasteConfig {
    var script = "Mousepaste.app"
    var showGui = true
    var pasteboardCopyDelay = 0.01
    var logLevel = LogLevel.info
    var debug:Bool { get { return logLevel <= .debug } }
    var trace:Bool { get { return logLevel <= .trace } }
}

var config = MousepasteConfig()

func setUserDefaults(){
    // TODO: add more settings
    UserDefaults.standard.set(Bundle.main.bundleIdentifier, forKey: "bundleID")
}

func parseArgs(_ args:[String] = CommandLine.arguments) -> MousepasteConfig {
    // TODO: Consider using more common way for parsing args.
    //       Is there a package that support sync/merge of settings and CLI args?
    debug("Mousepaste:Config:parseArgs")

    setUserDefaults()

    let script = CommandLine.arguments[0]
    let args = CommandLine.arguments[1...]

    func hasFlag(_ flag: String) -> Bool {
        return args.contains("-\(flag)") || args.contains("--\(flag)")
    }
    func hasCmd(_ cmd: String) -> Bool {
        return args.contains("\(cmd)")
    }

    if hasCmd("help") {
        print("usage: \(script) [nogui|help] [-debug]")
        os.exit(EXIT_FAILURE)
    }

    let envDebug = ProcessInfo.processInfo.environment["DEBUG"] ?? ""
    let showDebugLog = hasFlag("debug") || envDebug != ""

    return MousepasteConfig(
        script:  script,
        showGui: !hasFlag("nogui"),
        pasteboardCopyDelay: config.pasteboardCopyDelay,
        logLevel:  showDebugLog ? .debug : config.logLevel
    )
}
