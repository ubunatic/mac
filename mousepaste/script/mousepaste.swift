#!/usr/bin/env swift -O
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
// ----------------------------
// GENERATED CODE, DO NOT EDIT!
// ----------------------------
//
// This file is a concatenation of the following sources:

// * Sources/Mousepaste/main.swift
// * Sources/Mousepaste/Logging.swift
// * Sources/Mousepaste/Service.swift
// * Sources/Mousepaste/Config.swift
// * Sources/Mousepaste/Accessibility.swift
// * Sources/Mousepaste/Instance.swift
// * Sources/Mousepaste/Settings.swift
// * Sources/Mousepaste/Watcher.swift
// * Sources/Mousepaste/AppDelegate.swift
// * Sources/Mousepaste/Selection.swift
// * Sources/Mousepaste/Pasteboard.swift

// START merged imports
import AppKit
import ApplicationServices
import Darwin
import Foundation
import os
// END merged imports

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/main.swift
//


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

//
// END file: Sources/Mousepaste/main.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Logging.swift
//

// Logging implements a simple logger package that wraps the native print function.

enum LogLevel:Int {
    case trace = -1
    case debug = 0
    case info  = 1
    case warn  = 2
    case error  = 3

    static func <= (a:LogLevel, b:LogLevel) -> Bool { return a.rawValue <= b.rawValue }
}

private func logAny(_ prefix:String, _ val:Any?) {
    let tab = prefix.count < 8 ? "\t" : ""
    print(prefix + tab, val ?? val.debugDescription)
}

func debugValue(_ key:Any?, _ value:Any?) {
    if config.logLevel <= .debug {
        logAny("DEBUG.VALUE:", "\(key ?? key.debugDescription) = \(value ?? value.debugDescription)")
    }
}

func trace(_ val:Any?) { if config.logLevel <= .trace { logAny("DEBUG.TRACE:", val) } }
func debug(_ val:Any?) { if config.logLevel <= .debug { logAny("DEBUG:", val) } }
func info(_ val:Any?)  { if config.logLevel <= .info  { logAny("INFO:", val) } }
func warn(_ val:Any?)  { if config.logLevel <= .warn  { logAny("WARNING:", val) } }
func error(_ val:Any?) { if config.logLevel <= .error { logAny("ERROR:", val) } }
//
// END file: Sources/Mousepaste/Logging.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Service.swift
//


@objc protocol Service {
    func stop()
    func start()
    var isActive:Bool { get }
}
//
// END file: Sources/Mousepaste/Service.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Config.swift
//



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
//
// END file: Sources/Mousepaste/Config.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Accessibility.swift
//

// This accessibility package implements key pressoing, detection of selected
// UI elements and detection of selected text. It relys on the system's
// accessibility API. The host app must be added to trusted applications in
// Security > Privacy > Accessibility.


let kTrusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
let kTrustedOptions = [kTrusted:true] as CFDictionary
let kFocused = kAXFocusedUIElementAttribute as CFString
let kSelected = kAXSelectedTextAttribute as CFString

// ensureTrustedAccess returns whether or not Accessibility is enabled.
func ensureTrustedAccess() -> Bool {
    debug("Mousepaste:Accessibility:ensureTrustedAccess")
    let trusted = AXIsProcessTrustedWithOptions(kTrustedOptions)
    if trusted {
        print("Accessibility preferences enabled")
    } else {
        print("ERROR: Accessibility preferences not enabled")
    }
    return trusted
}

func hasTextInputFocus() -> Bool {
    // First Try: Total failure using accessibility attributes!
    //
    // return isTextInput(getFocusedElement())
    //
    // AXUI properties will not work in many apps. We need something else
    // to know which type of UI is under the cursor and if it supports text input.

    // Second Try: Think like a human!
    // How do you as a human know that your mouse is hovering a text field?
    // Yes! The mouse cursor will tell you; even in a terminal.
    //
    // Awesome, let's hack the system cursor!
    //
    // We just need to check if the system cursor is the "iBeam" cursor.
    guard let cursor = NSCursor.currentSystem else { return false }
    let iBeam = NSCursor.iBeam
    //
    // But comparing two plain objects wont work. We need something more robust.
    // Fortunately we can access the cursor image and its bytes as an invariant.
    let cursorImage = cursor.image.tiffRepresentation
    let iBeamImage = iBeam.image.tiffRepresentation
    // Awesome, bytes can be easily compared! Done.
    return cursorImage == iBeamImage

    // TODO: Is there a better option to learn about potential text-input UI
    //       located under the cursor?
}

func isTextInput(_ elem:AXUIElement?) -> Bool {
    if elem == nil {
        return false
    }

    // This type check was useless: In VSCode all UI elements had the same type!
    // TODO: are there better ways to check UI types that work well in Electron apps?
    let type = CFGetTypeID(elem)
    switch type {
    default:
        if config.debug { debug("CFTypeID: \(type)") }
    }

    return false
}

func getElementTypeUnderCursor() {
    // TODO: try other focussed UI elements and not only kAXFocusedUIElementAttribute
}

// getFocusedElement returns the currently focused AXUIElement.
func getFocusedElement() -> AXUIElement? {
    var focused: AnyObject?
    let err = AXUIElementCopyAttributeValue(AXUIElementCreateSystemWide(), kFocused, &focused)
    if err != .success || CFGetTypeID(focused) != AXUIElementGetTypeID() {
        return nil
    }
    let elem = focused as! AXUIElement
    return elem
}

// getFocusedSelection returns the selected text of the currently focused AXUIElement.
//
// Accessibility will usually be able to copy kAX* attributes,
// even if the app does not support them. In this case the value is empty.
// As a result, we cannot distinguish between empty and nil.
func getFocusedSelection() -> String {
    guard let elem = getFocusedElement() else { return "" }

    var any: AnyObject?
    let err = AXUIElementCopyAttributeValue(elem, kSelected, &any)
    if err != .success || any == nil {
        return ""
    }
    let val = any as! String

    // if val != nil --> provider is AX
    //
    // TODO: Add more AX checks if the UI Element is a text field.
    //       For instance if quickly clicking in in Finder,
    //       the selected file name will be considered.

    return val
}

class CmdKeyPresser {
    static let Cmd = CGEventFlags.maskCommand
    static let C: UInt16 = 0x08
    static let V: UInt16 = 0x09

    func press(_ key:UInt16) {
        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true) else { return }
        down.flags = CmdKeyPresser.Cmd
        down.post(tap: CGEventTapLocation.cghidEventTap)
        guard let up = CGEvent(keyboardEventSource: CGEventSource(event: down), virtualKey: key, keyDown: false) else { return }
        up.post(tap: CGEventTapLocation.cghidEventTap)
    }
}
//
// END file: Sources/Mousepaste/Accessibility.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Instance.swift
//

// Instance package implements checking for multiple instances of an app.
// Checks are based on the bundle ID and executable URL and require
// access to NSRunningApplication and NSWorkspace.


// isSingleInstance returns whether or not the current apps instance count
// is bigger than `maxCount`.
// If called from your main (e.g., in CLI mode), use maxCount = 0 (default).
// If called after applicationDidFinishLaunching, use maxCount = 1.
func isSingleInstance(maxCount:Int = 0) -> Bool {
    debugValue("Bundle.main.bundleIdentifier", Bundle.main.bundleIdentifier)
    debugValue("Bundle.main.executableURL", Bundle.main.executableURL)
    if Bundle.main.bundleIdentifier != nil {
        // find apps with same bundleIdentifier
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!)
        debugValue("others.count", others.count)
        if others.count > maxCount {
            return false
        }

        // find apps with same executable
        let apps = NSWorkspace.shared.runningApplications.filter { app in
            return app.executableURL == Bundle.main.executableURL
        }
        debugValue("apps.count", apps.count)
        if apps.count > maxCount {
            return false
        }
    }
    return true
}
//
// END file: Sources/Mousepaste/Instance.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Settings.swift
//


class Settings: NSViewController {
	var prefsWindow:NSWindow?
	let delaySlider = NSSlider.init()
	let delayText = NSTextField.init()

    override func loadView() {
        view = NSView()
    }

	var window: NSWindow {
		if prefsWindow != nil {
			return prefsWindow!
		}
		let w = NSWindow(
			contentRect:  NSRect(origin: .zero, size: .init(width: 200, height: 100)),
            styleMask: [.closable],
            backing: .buffered,
            defer: false
		)
        w.title = "Settings"
        w.isOpaque = false
        w.center()
        w.isMovableByWindowBackground = true
        w.backgroundColor = NSColor(calibratedHue: 0, saturation: 1.0, brightness: 0, alpha: 0.7)
        // w.makeKeyAndOrderFront(nil)
		w.contentViewController = self
		prefsWindow = w

		print("window built")
		return w
	}

	@IBAction func sliderValueChanged(_ sender: NSSlider) {
		setDelayText()
	}

	@IBAction func cancelButtonClicked(_ sender: Any) {
		window.close()
	}

	@IBAction func okButtonClicked(_ sender: Any) {
		savePrefs()
		window.close()
	}

	func loadPrefs() {
		let delayMs = Int(config.pasteboardCopyDelay * 1000.0)
		delaySlider.isEnabled = true
		delaySlider.integerValue = delayMs
		setDelayText()
		print("config loaded")
	}

	func savePrefs() {
		config.pasteboardCopyDelay = delaySlider.doubleValue / 1000.0
		NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged"), object: nil)
	}

	func setDelayText() {
		delayText.stringValue = "\(delaySlider.doubleValue) ms"
	}
}
//
// END file: Sources/Mousepaste/Settings.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Watcher.swift
//

// Watcher package implements a mouse event monitor
// for captruring selection actions done with the mouse.


typealias Mask = NSEvent.EventTypeMask
typealias Type = NSEvent.EventType

class Watcher: Service {
    var dragging = false
    var selection = ""
    var observer:Any?

    func handleEvent(e: NSEvent) -> Void {
        let isLeftUp = e.type == Type.leftMouseUp
        let isOtherUp = e.type == Type.otherMouseUp
        let isDrag = e.type == Type.leftMouseDragged
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
            if config.debug { print("removed observer: \(observer.debugDescription)") }
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
        if config.debug { print("added observer: \(observer.debugDescription)") }
        print("Starting mouse selection watcher")
    }

    var isActive: Bool {
        get { return observer != nil }
    }

    let selectionMask:Mask = [
        Mask.leftMouseDown, Mask.leftMouseUp,
        Mask.otherMouseDown, Mask.otherMouseUp,
        Mask.leftMouseDragged
    ]

    static let shared = Watcher()
}
//
// END file: Sources/Mousepaste/Watcher.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/AppDelegate.swift
//


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
        app.setActivationPolicy(.accessory)
        DispatchQueue.main.async {
            self.window.orderOut(self)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
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
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

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
//
// END file: Sources/Mousepaste/AppDelegate.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Selection.swift
//


class SelectionEvent {
    enum EventType:Int {
        case Copy, Paste
    }

    enum SelectionProvider {
        case None, AX, KeyPress
    }

    var type:EventType
    var description:String

    var backup = ""
    var selected = ""
    var restored = ""
    var provider = SelectionProvider.None

    static var sharedText = ""

    // A serialQueue allows serializing function calls to
    // avoid data races from concurrent events.
    static let serialQueue = DispatchQueue(label: "SelectionEvent.serialQueue")

    init(_ type:EventType, _ description:String) {
        self.type = type
        self.description = description
    }

    // execute processes the selection event serialized with other selection events.
    func execute() {
        SelectionEvent.serialQueue.sync {
            unsafeExecute()
        }
    }

    // unsafeExecute processes the selection event immediately.
    private func unsafeExecute()  {
        backup = readPasteboard()
        switch type {
        case .Copy:
            (selected, provider) = GetSelection()
            if selected != "" {
                SelectionEvent.sharedText = selected
            }
        case .Paste:
            if hasTextInputFocus() {
                PasteSelection(SelectionEvent.sharedText)
            }
        }
        restored = readPasteboard()
        if config.debug { print(describe()) }
    }

    func describe() -> String {
        return ("SelectionEvent(" +
            "backup:\(backup), " +
            "selected:\(selected), " +
            "restored:\(restored), " +
            "provider:\(provider))"
        )
    }
}

func GetSelection() -> (String, SelectionEvent.SelectionProvider) {
    let val = getFocusedSelection()
    if val != "" {
        return (val, .AX)
    }
    return (CopySelectionFromPasteboard(), .KeyPress)
}

func CopySelectionFromPasteboard() -> String {
    backupPasteboard()
    defer { restorePasteboard() }

    // Must clear pasteboard to allow reading empty selection!
    // VSCode for instance will not copy anyting on Cmd+C unless
    // "editor.emptySelectionClipboard" is true.
    // If not cleared, readPasteboard will later read anything that is left on
    // the pasteboard instead of the selected (empty) text.
    clearPasteboard()

    // TODO: a) find alternative to detect empty selection
    // TODO: b) determine if Cmd+C had any effect
    // TODO: c) determine if Cmd+C will have any effect before even sending the keypress
    sendCopyCommand()
    Thread.sleep(forTimeInterval: config.pasteboardCopyDelay)
    return readPasteboard()
}

func PasteSelection(_ val:String) {
    backupPasteboard()
    defer { restorePasteboard() }

    writePasteboard(val)
    sendPasteCommand()
    Thread.sleep(forTimeInterval: config.pasteboardCopyDelay)
}
//
// END file: Sources/Mousepaste/Selection.swift
//

// GENERATED CODE, DO NOT EDIT!
//
// START file: Sources/Mousepaste/Pasteboard.swift
//

// Pasteboard package implements basic Pasteboard access.
// It is used by Watcher package to use the Pasteboard as
// buffer to access non-reachable text, i.e., selectedText
// that is not exposed via AXUI attributes.


let cmdKeyPresser = CmdKeyPresser()
var backupValue = ""

func sendCopyCommand() {
    cmdKeyPresser.press(CmdKeyPresser.C)
}

func sendPasteCommand() {
    cmdKeyPresser.press(CmdKeyPresser.V)
}

func readPasteboard() -> String {
    guard let val = NSPasteboard.general.string(forType: .string) else {
        return ""
    }
    return val
}

func writePasteboard(_ val:String) {
	if val == "" {
		return
	}
    clearAndWritePasteboard(val)
}

func clearPasteboard() {
    NSPasteboard.general.clearContents()
}

func clearAndWritePasteboard(_ val:String) {
    NSPasteboard.general.clearContents()
	NSPasteboard.general.setString(val, forType: .string)
}

func backupPasteboard() {
    let val = readPasteboard()
    if val != backupValue {
        backupValue = val
    }
}

func restorePasteboard() {
    clearAndWritePasteboard(backupValue)
}
//
// END file: Sources/Mousepaste/Pasteboard.swift
//


// START main
main()
// END main

