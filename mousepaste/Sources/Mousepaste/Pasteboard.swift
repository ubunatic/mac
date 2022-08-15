// Pasteboard package implements basic Pasteboard access.
// It is used by Watcher package to use the Pasteboard as
// buffer to access non-reachable text, i.e., selectedText
// that is not exposed via AXUI attributes.

import SwiftUI  // needed for NS* classes
import Appster
import Logging

// PBData minics NSPasteboardItem to preserve the fully specified
// Pasteboard data. This allows Mousepaste to restore the data after
// using the Pasteboard to capture and paste selections.
//
// Using the system NSPasteboardItem directly had unwanted side effects
// when the pasteboard was cleared. The data was lost in this case.
//
public struct PBData {
    let data:Data?
    let type:NSPasteboard.PasteboardType

    public func isText() -> Bool {
        return IsTextItem(type)
    }

    public func Text() -> String {
        guard let data = data else {
            return ""
        }

        // TODO: Is there a better way to convert copied text bytes to string?
        let item = NSPasteboardItem()
        item.setData(data, forType: type)
        return item.Text()
    }
}

// PBItem is a complete Pasteboard item with separately stored representations of the data.
public struct PBItem {
    // captured data representations of various tpyes for this Pasteboard item.
    public var data:[PBData] = []

    // Text returns the string data representation of the Pasteboard item.
    public func Text() -> String {
        for d in data {
            if d.type == .string {
                return d.Text()
            }
        }
        return ""
    }
}

extension MP {
    static let cmdKeyPresser = CmdKeyPresser()
    // TODO: Support other backup types (and restirong them)
    //       or use a list of backups and rearrange them accordingly.
    static var backupValue:[PBItem] = []
}

func IsTextItem(_ t:NSPasteboard.PasteboardType) -> Bool {
    return (
        t == .string ||
        t == .rtf ||
        t == .html ||
        t == .URL ||
        t == .fileURL
    )
}

extension NSPasteboardItem {
    public func isText() -> Bool {
        self.types.contains { t in IsTextItem(t) }
    }

    public func PBDataItems() -> [PBData] {
        var res:[PBData] = []
        for t in types {
            let pb = PBData(
                data:data(forType: t),
                type:t
            )
            res.append(pb)
        }
        return res
    }

    public func Text() -> String {
        return self.string(forType: .string) ?? ""
    }
    public func Html() -> String {
        return self.string(forType: .html) ?? ""
    }
}

func sendCopyCommand() {
    MP.cmdKeyPresser.press(CmdKeyPresser.C)
}

func sendPasteCommand() {
    MP.cmdKeyPresser.press(CmdKeyPresser.V)
}

func readPasteboard() -> [PBItem] {
    let pb = NSPasteboard.general

    guard let items = pb.pasteboardItems else {
        // debugValue("readPasteboard", "<empty>")
        return []
    }

    var contents:[PBItem] = []

    for item in items.reversed() {
        let data = item.PBDataItems()
        contents.append(PBItem(data:data))
    }

    return contents
}

func writePasteboard(_ val:String) {
	if val == "" {
		return
	}
    let item = NSPasteboardItem()
    item.setString(val, forType: .string)
    clearAndWritePasteboard([PBItem(
        data: [PBData(
            data: item.data(forType: .string),
            type: .string
        )]
    )])
}

func clearPasteboard() {
    NSPasteboard.general.clearContents()
}

func clearAndWritePasteboard(_ items:[PBItem]) {
    NSPasteboard.general.clearContents()
    for item in items {
        for d in item.data {
            NSPasteboard.general.setData(d.data, forType: d.type)
        }
    }
}

func backupPasteboard() {
    let items = readPasteboard()
    MP.backupValue = items
    debugValue("backed up", items)
}

func restorePasteboard() {
    let items = MP.backupValue
    debugValue("restoring", TextFromPBItems(items))
    clearAndWritePasteboard(items)
}
