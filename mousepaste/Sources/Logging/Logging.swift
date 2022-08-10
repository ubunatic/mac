// Logging implements a simple logger package that wraps the native print function.
import Foundation
import os

public let ERR = EXIT_FAILURE
public let OK = EXIT_SUCCESS

public class LoggerConfig:ObservableObject {
    @Published public var level:LogLevel = .info
    @Published public var log:(String) -> Void = { print($0) }

    public var info:Bool  { get { return level <= .info } }
    public var debug:Bool { get { return level <= .debug } }
    public var trace:Bool { get { return level <= .trace } }
    public func toggleDebug() {
        level = debug ? .info : .debug
        Logging.info("setting log level to \(level) (debug = \(debug))")
    }
}

public let LogConfig = LoggerConfig()

public enum LogLevel:Int {
    case trace = -1
    case debug = 0
    case info  = 1
    case warn  = 2
    case error  = 3

    public static func <= (a:LogLevel, b:LogLevel) -> Bool { return a.rawValue <= b.rawValue }
}

private func logAny(_ prefix:String, _ val:Any?) {
    let space = prefix.count < 8 ? "\t" : " "
    let msg = "\(prefix)\(space)\(val ?? val.debugDescription)"
    LogConfig.log(msg)
}

public func valueString(_ value:Any?) -> String {
    switch value {
    case nil: return "\(value.debugDescription)(nil)"
    default:  return "\(value!)"
    }
}

public func printValue(_ key:Any?, _ value:Any?) {
    let (key, count) = observeKey(key)
    var countHint = ""
    if LogConfig.debug {
        countHint = "#\(count)"
    }
    logAny("\(LogConfig.level).value:", "\(key)\(countHint) = \(valueString(value))")
}

private func observeKey(_ key:Any?) -> (String, Int) {
    let key = "\(key ?? type(of: key))"
    if debugValueCount[key] != nil {
        debugValueCount[key]! += 1
    } else {
        debugValueCount[key] = 1
    }
    return (key, debugValueCount[key]!)
}

var debugValueCount:[String:Int] = [:]

public func debugValue(_ key:Any?, _ value:Any?) {
    if LogConfig.debug  { printValue(key, value) }
}

public func infoValue(_ key:Any?, _ value:Any?) {
    if LogConfig.info { printValue(key, value) }
}

public func trace(_ val:Any?) { if LogConfig.level <= .trace { logAny("DEBUG.TRACE:", val) } }
public func debug(_ val:Any?) { if LogConfig.level <= .debug { logAny("DEBUG:", val) } }
public func info(_ val:Any?)  { if LogConfig.level <= .info  { logAny("INFO:", val) } }
public func warn(_ val:Any?)  { if LogConfig.level <= .warn  { logAny("WARN:", val) } }
public func error(_ val:Any?) { if LogConfig.level <= .error { logAny("ERROR:", val) } }
public func fatal(_ val:Any?) { if LogConfig.level <= .error { logAny("FATAL:", val); os.exit(ERR) } }
