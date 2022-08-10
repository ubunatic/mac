import SwiftUI
import Logging
import Appster

public struct SettingsView: View {
    @StateObject var state = MousepasteConfig.shared

    func getDelayMillis() -> String {
        return String(format: "%.fms", $state.pasteboardCopyDelay.wrappedValue * 1000)
    }

	func clear() { clearConfigAndUserDefaults() }
    func debug() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if LogConfig.debug { HStack {
                Text("MP 18x18:")
                Images.MousepasteIcns.resizable().frame(width: 18, height: 18)
                Text("MP 20x20:")
                Images.MousepasteIcns.resizable().frame(width: 20, height: 20)
                Text("AppIcon")
                Images.AppIcon.image
            }}

            HStack { Toggle("Show colored menu icons",         isOn: $state.fancyGui) }
            HStack { Toggle("Start capturing when app starts", isOn: $state.autoStart) }
            HStack { Toggle("Start Mousepaste on login (WIP)", isOn: $state.autoLoad) }
            HStack {
                Slider(value: $state.pasteboardCopyDelay)
                Text(getDelayMillis())
                Text("Pasteboard delay")
            }.help("Delay in Milliseconds before sending ⌘C when copying selection from non-Cocoa UIs")
            HStack {
                if LogConfig.debug {
                    Button(action: debug) { Text("Debug") }
                }
                Button(state.fancyGui ? Icons.Clear : "Restore Defaults", action: clear)
                    .help("Clear stored settings and load defaults")
            }
        }
        .frame(width: 400, height: 200)
        .padding(20)
        .onAppear {
            info("SettingsView.appear")
        }
        .onDisappear {
            info("SettingsView.disappear")
        }
    }
}
