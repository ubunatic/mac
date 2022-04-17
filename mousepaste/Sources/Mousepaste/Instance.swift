// Instance package implements checking for multiple instances of an app.
// Checks are based on the bundle ID and executable URL and require
// access to NSRunningApplication and NSWorkspace.

import ApplicationServices
import AppKit

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
