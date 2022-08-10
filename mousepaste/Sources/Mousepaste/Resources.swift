import SwiftUI

struct Icons {
    static let Mousepaste = "🐭"
    static let Door = "🚪"
    static let Play = "▶️"
    static let Stop = "⏹"
    static let Quit = "❌"
    static let Broom = "🧹"
    static let Paste = "📋"
    static let Empty = "∅"
    static let Bug = "🪲"
    static let Clear = "🧹"
    static let Gear = "⚙️"
    static let OpenFolder = "📂"
    static let Save = "💾"
}

struct Texts {
    static let Clear = "Clear Settings"
    static let Start = "Start"
    static let Stop  = "Stop"
    static let Quit  = "Quit"
    static let Prefs = "Settings"
    static let Debug = "Debug"
}

extension NSImage {
    // image returns a SwiftUI.Image that wraps the original NSImage
    var image:Image {
        Image(nsImage: self)
    }
    // resizable returns the NSImage as resizable SwiftUI.Image.
    func resizable() -> Image {
        self.image.resizable()
    }
}

public struct Images {
    static let MousepasteIcns = Bundle.main.image(forResource: "Mousepaste.icns")!
    static let Icon1Svg = Image("Mousepaste.svg")

    public static let AppIcon = NSImage(
        // TODO: support Hi-DPI mode
        size: NSSize.init(width: 20.0, height: 20.0),
        flipped: false,
        drawingHandler: { rect in
            Bundle.main.image(forResource: "Mousepaste.icns")?.draw(in: rect)
            // Icons.Mousepaste.draw(in: rect)
            return true
        }
    )
}
