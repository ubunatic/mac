import Foundation

@objc public protocol Service {
    func stop()
    func start()
    var isActive:Bool { get }
}