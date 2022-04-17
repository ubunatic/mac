import Foundation
import ApplicationServices

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
