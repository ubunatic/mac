// Config package to manage runtime config, allow override via the command line
// and load and store User Defaults (aka. Settings or Preferences)

import Foundation
import Logging

struct Setting {
    static let autoStart = "autoStart"
    static let autoLoad = "autoLoad"
    static let fancyGui = "fancyGui"
    static let pasteboardCopyDelay = "pasteboardCopyDelay"
}

private let fallbackBundleId = "com.ubunatic.mousepaste"
// MousepasteConfig stores the runtime config for Mousepaste.
// It is populated either by the CommandLine args or through UserDefaults.
public class MousepasteConfig:ObservableObject {
    var bundleId = Bundle.main.bundleIdentifier ?? fallbackBundleId
    var resourcePath = Bundle.main.resourcePath
    var script = "Mousepaste.app"

    public static var shared:MousepasteConfig { MP.config }

    @Published var autoStart = true
    @Published var autoLoad = false
    @Published var showGui = true
    @Published var fancyGui = false
    @Published var pasteboardCopyDelay = 0.02

    init(){}

    public init(
        autoStart:Bool,
        showGui:Bool,
        fancyGui:Bool,
        pasteboardCopyDelay:Double
    ){
        self.autoStart = autoStart
        self.showGui = showGui
        self.fancyGui = fancyGui
        self.pasteboardCopyDelay = pasteboardCopyDelay
    }

    public func apply(_ from:MousepasteConfig) {
        debugValue("applying", from)
        self.autoStart = from.autoStart
        self.autoLoad = from.autoLoad
        self.showGui = from.showGui
        self.fancyGui = from.fancyGui
        if !from.pasteboardCopyDelay.isNaN {
            self.pasteboardCopyDelay = from.pasteboardCopyDelay
        }
        debugValue("applied", self)
    }

    public func clear(){ apply(MousepasteConfig()) }
}

// MP is the global Mousepaste object used to access anything static.
struct MP {
    // config is the shared MousepasteConfig of the app.
    static let config = MousepasteConfig()
    // ud are the shared UserDefaults of the app.
    static var ud:UserDefaults { UserDefaults.standard }
}

extension UserDefaults {
    func receive<Value>(_ k:String, _ fn:(Value) -> Void) {
        guard let val = self.value(forKey: k) else { return }
        fn(val as! Value)
    }
}

// saveUserDefaults saves are preservable settings to the application's UserDefaults.
func saveUserDefaults(_ from:MousepasteConfig=MP.config){
    MP.ud.set(from.autoStart,           forKey: Setting.autoStart)
    MP.ud.set(from.autoLoad,            forKey: Setting.autoLoad)
    MP.ud.set(from.fancyGui,            forKey: Setting.fancyGui)
    MP.ud.set(from.pasteboardCopyDelay, forKey: Setting.pasteboardCopyDelay)
    debugValue("saved delay", from.pasteboardCopyDelay)
}

// loadUserDefaults loads stored settings from the application's UserDefaults
// and stores them in the given destination Config.
func loadUserDefaults(_ dest:MousepasteConfig=MP.config) {
    MP.ud.receive(Setting.autoStart)           { dest.autoStart = $0 }
    MP.ud.receive(Setting.autoLoad)            { dest.autoLoad = $0 }
    MP.ud.receive(Setting.fancyGui)            { dest.fancyGui = $0 }
    MP.ud.receive(Setting.pasteboardCopyDelay) { dest.pasteboardCopyDelay = $0 }
}

func clearUserDefaults() {
    UserDefaults.standard.removePersistentDomain(forName: MP.config.bundleId)
}

func clearConfigAndUserDefaults() {
    clearUserDefaults()
    MP.config.clear()
}
