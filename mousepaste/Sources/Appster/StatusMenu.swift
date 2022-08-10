import SwiftUI
import Logging

// StatusMenu wraps NSMenu, to allow for declarative definition of a complete NSMenu
// with wrapped NSMenuItem using closures instead of selectors.
//
// ⚠️ Force-enables all items ⚠️ (to compensate a SwiftUI bug on MacOS)
//
public class StatusMenu: NSMenu {
    var icon: NSImage?

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }

    required public init(_ icon:NSImage?, _ menuItems:NSMenuItem...){
        self.icon = icon
        super.init(title: "Status Menu")

        // autoEnabling does not work safely with SwiftUI Apps
        // TODO: Try to use a default NSApplicationDelegate only for managing the status bar menu.
        autoenablesItems = false
        for item in menuItems {
            addItem(item)
        }
    }
}

// MenuItem wraps NSMenuItem, accepting a closure instead of a selector as action.
// The item will be enabled by default.
public class MenuItem: NSMenuItem {
    static let CMD = NSEvent.ModifierFlags.command

    var fn:()->() = {}

    @IBAction
    func menuAction(sender:Any?) { fn() }

    public init(_ title:String, action: @escaping() -> (), keyEquivalent:String="") {
        // TODO: allow SwiftUI-style keyboardShortcut string with modifier
        fn = action
        super.init(title: title, action: nil, keyEquivalent: keyEquivalent)
        self.action = #selector(self.menuAction)
        self.target = self
        self.isEnabled = true
    }

    required init(coder: NSCoder) { super.init(coder: coder) }

    public func visible(_ isVisible: Bool=true) -> MenuItem {
        self.isHidden = !isVisible
        return self
    }

    public func hidden(_ isHidden: Bool=true) -> MenuItem {
        self.isHidden = isHidden
        return self
    }

    public func keyboardShortcut(_ key:String="", _ flags:NSEvent.ModifierFlags=NSEvent.ModifierFlags()) -> MenuItem {
        keyEquivalent = key
        keyEquivalentModifierMask = flags
        return self
    }
}

// StatusMenuItem is a SwiftUI rebuild of a NSMenuItem.
//
// 🚧 work in progress 🚧
//
// Usage:
//
// * put them in an VStack
// * host stack in a NSHostingView
// * set as statusItem.view
//
// Open Issues:
//
// * activation of the current App when opening the status menu
// * multi-screen support (menu does not open on 2nd screen)
//
// If the app becomes inactive, the status menu is no longer enabled.
// and calling NSApp.activate(..) leads to unexpected behavior.
//
public struct StatusMenuItem: View, Identifiable {
    @State var hovering: Bool = false
    public var id = UUID()
    public let title:String
    public let action:()->()
    public let keyEquivalent:String

    let transparent:Color = Color(nsColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))
    let hairSpace = " "
    let thinSpace = " "

    public init(_ title:String, action: @escaping () -> (), keyEquivalent:String="") {
        self.title = title
        self.action = action
        self.keyEquivalent = keyEquivalent
    }

    public var body: some View {
        Button(action: {
            action()
        })
        {
            HStack {
                Text(title)
                .foregroundColor(hovering ? .white : .primary)
                Spacer()
                Text("⌘\(hairSpace)\(keyEquivalent.uppercased())")
                .foregroundColor(hovering ? .white : .secondary)
            }
            .cornerRadius(0)
            .padding(3)
            .background(hovering ? Color.accentColor : transparent)
        }
        .buttonStyle(.borderless)
        .cornerRadius(5)
        .padding(0)
        .onHover {
            hovering = $0
            if hovering { debug("hovering") }
        }
    }
}
