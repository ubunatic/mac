import Foundation

@objc protocol Service {
    func stop()
    func start()
    var isActive:Bool { get }
}