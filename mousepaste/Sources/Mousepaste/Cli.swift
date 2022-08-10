import Foundation
import ArgumentParser
import Appster
import Logging
import os

struct MousepasteCli: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mousepaste",
        abstract: "Mousepaste!",
        version: "v0.0.1"
    )

    static let inputLoop = InputLoop()

    @Flag(help: "run without GUI")                  var nogui = false
    @Flag(help: "do not autostart the watcher")     var nostart = false
    @Flag(help: "use more GUI icons and less text") var fancy = false
    @Flag(help: "use more GUI icons and less text") var debug = false

    func run() {
        // load user defaults before considering commandline args
        loadUserDefaults()

        // set log level based on CLI args or ENV
        let envDebug = ProcessInfo.processInfo.environment["DEBUG"] ?? ""
        let showDebugLog = debug || envDebug != ""
        LogConfig.level = showDebugLog && !LogConfig.debug ? .debug : LogConfig.level

        // merge CLI arguments with default values and update shared config
        MousepasteConfig.shared.apply(
            MousepasteConfig(
                autoStart:           MousepasteConfig.shared.autoStart && !nostart,
                showGui:             MousepasteConfig.shared.showGui && !nogui,
                fancyGui:            MousepasteConfig.shared.fancyGui || fancy,
                pasteboardCopyDelay: MousepasteConfig.shared.pasteboardCopyDelay
            )
        )
    }

    static func exitOnSigInt() -> Void {
        print("Press Ctrl+C to stop Mousepaste.")
        signal(SIGINT) { _ in
            MousepasteCli.exit(OK, "Mousepaste.app stopped by SIGINT")
        }
    }
    static func exit(_ code:Int32=OK, _ message: String="") -> Void {
        if message != "" {
            error(message)
        }
        os.exit(code)
    }
}

class InputLoop : Service {
    var commands:[(String, () -> ())] = []
    var receivedEmptyLines = 0

    var isActive: Bool = false

    // onKeyPress adds a function as command to the loop's commands.
    func onKeyPress(_ key:String, _ fn: @escaping () -> ()) {
        commands.append((key, fn))
    }

    // start registers the terminal input handler.
    func start() {
        FileHandle.standardInput.readabilityHandler = handleInput
        isActive = true
        debug("starting InputLoop to read from standardInput")
        debugValue("commands", commands)
    }

    // stop deregisters the terminal input handler.
    func stop() {
        FileHandle.standardInput.readabilityHandler = nil
        isActive = false
    }

    func handleInput(pipe: FileHandle) {
        if let line = String(data: pipe.availableData, encoding: .utf8) {
            let got = line.trimmingCharacters(in: .whitespacesAndNewlines)
            // BUG: Handling stdin-piped lines via FileHandle.standardInput leads to an endless loop! 🍎, WTF! 🤷
            //      Manual input does not have this issue.
            // ❔: Why does piping a single line lead to an input loop?

            // Observation:
            //     1.Manual input cannot be mixed with a regular pipe input.
            //       [?] Is there a difference between terminal input and stdin on MacOS?
            //
            //     2. Somehow app-produced output also produces empty lines on stdin.
            //        The issue can be mitigated by ignoring empty strings.
            //        You must prevent any output from being produced on receiving ""
            //        (or any thing else) to break the chain.
            //
            //     3. Stopping on "", but still allowing debug logs in all other cases seem to work.
            //        The feedback loop only seems to produce empty lines and not echo the actual output.
            //
            if got.elementsEqual("") {
                receivedEmptyLines += 1
                // You can test the loop bug as follows:
                //
                //     echo d | ./Mousepaste.app/Contents/MacOS/Mousepaste --debug
                //
                // You must enable the following line to trigger the bug.
                // debugValue("receivedEmptyLines", self.receivedEmptyLines)
                return
            }
            for (k, fn) in self.commands {
                if got.elementsEqual(k) {
                    fn()
                    return
                }
            }
            // debugValue("receivedEmptyLines", self.receivedEmptyLines)
            debugValue("commands", self.commands)
            debug("unknown command: \(line)")
        }
    }
}
