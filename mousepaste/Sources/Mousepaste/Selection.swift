import SwiftUI
import Appster
import Logging

// SelectionEvent represents the properties of a text selection event
// triggered by the mouse or other forms of input.
// The supported event types are Copy and Paste.
class SelectionEvent {
    enum EventType:Int {
        case Copy, Paste
    }

    enum SelectionProvider {
        case None, AX, KeyPress
    }

    var type:EventType
    var description:String

    var backup:[PBItem] = []
    var selected = ""
    var restored:[PBItem] = []
    var provider = SelectionProvider.None

    static var sharedText = ""

    // A serialQueue allows serializing function calls to
    // avoid data races from concurrent events.
    static let serialQueue = DispatchQueue(label: "SelectionEvent.serialQueue")

    static func clear() {
        sharedText = ""
    }

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
            if AX.hasTextInputFocus() {
                PasteSelection(SelectionEvent.sharedText)
            }
        }
        restored = readPasteboard()
        if LogConfig.debug { print(describe()) }
    }

    func describe() -> String {
        return ("SelectionEvent(\(provider), \(selected))  # " +
            "💾 \(TextFromPBItems(backup))  " +
            "📲 \(TextFromPBItems(restored))  " +
            // "shared == selected: \(SelectionEvent.sharedText == selected))" +
            ""
        )
    }
}

func GetSelection() -> (String, SelectionEvent.SelectionProvider) {
    let val = AX.getFocusedSelection()
    if val != "" {
        return (val, .AX)
    }
    return (CopySelectionFromPasteboard(), .KeyPress)
}

func CopySelectionFromPasteboard() -> String {
    debugValue("backupValueBeforeBackup:", TextFromPBItems(MP.backupValue) + "  len:\(MP.backupValue.count)")
    backupPasteboard()
    debugValue("backupValueAfterBackup:", TextFromPBItems(MP.backupValue) + "  len:\(MP.backupValue.count)")
    defer { restorePasteboard() }

    // Sometimes Cmd+C will have no effect. VSCode for instance will not copy
    // anyting on Cmd+C unless "editor.emptySelectionClipboard" is true.
    // If not cleared and Cmd+C has no effect, we may be left with a wrong old
    // value on the pasteboard.

    // TODO: clear clears all content, also in any Object copies of it!
    //       This kills the backup feature. How can we preserve the items in the backup store?
    // clearPasteboard()

    // TODO: consider clearing only the top item or pushing an empty item to
    //       preserve other items that may ne be affected by Mousepaste
    // TODO: find alternative to detect empty selection
    // TODO: determine if Cmd+C will have any effect before even sending Cmd+C

    sendCopyCommand()
    // TODO: Determine if Cmd+C had any effect.
    // TODO: try to use NSPasteboard.general.changeCount to detect if something was copied

    // To ensure the system or external app can actually copy the text, we need
    // to give it some time to do so. Configuring this delay is tricky, since
    // some apps may be slower than other, system may be under load, hardware
    // may be different, etc. On the other hand, a too big value will feel
    // slow to the user who wants to mouse-paste the value after half a Second.
    Thread.sleep(forTimeInterval: MP.config.pasteboardCopyDelay)
    // TODO: Is Thread.sleep the right way for sleeping in modern swift?
    //       Note that the whole operation should be synchronous though
    //       to avoid serialization issues from multiple selection events.

    debugValue("backupValueAfterCopy:", TextFromPBItems(MP.backupValue) + "  len:\(MP.backupValue.count)")

    let text = TextFromPBItems(readPasteboard())
    if text != "" {
        // debugValue("text", text)
    }
    return text
}

func TextFromPBItems(_ items: [PBItem]) -> String {
    var text = ""
    for item in items {
        text += item.Text()
    }
    return text
}

func PasteSelection(_ val:String) {
    backupPasteboard()
    defer { restorePasteboard() }

    writePasteboard(val)
    sendPasteCommand()

    // See discussion in CopySelectionFromPasteboard
    Thread.sleep(forTimeInterval: MP.config.pasteboardCopyDelay)
}
