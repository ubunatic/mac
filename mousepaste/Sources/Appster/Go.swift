import Foundation

// Runs the given function `fn` asynchronously using the main DispatchQueue.
public func go(fn: @escaping () -> Void) {
    DispatchQueue.main.async(execute: fn)
}

// Runs the given function `fn` asynchronously after `ms` Milliseconds
// using the main DispatchQueue.
public func go(_ ms: Double, fn: @escaping () -> Void) {
    // DispatchTime is coded as Double: Seconds.FractionalSeconds.
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + ms/1000.0, execute: fn)
}
