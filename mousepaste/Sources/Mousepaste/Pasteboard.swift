// Pasteboard package implements basic Pasteboard access.
// It is used by Watcher package to use the Pasteboard as
// buffer to access non-reachable text, i.e., selectedText
// that is not exposed via AXUI attributes.

import Foundation
import AppKit

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
