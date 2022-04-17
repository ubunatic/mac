import Foundation
import AppKit

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
