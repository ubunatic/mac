// Logging implements a simple logger package that wraps the native print function.

enum LogLevel:Int {
    case trace = -1
    case debug = 0
    case info  = 1
    case warn  = 2
    case error  = 3

    static func <= (a:LogLevel, b:LogLevel) -> Bool { return a.rawValue <= b.rawValue }
}

private func logAny(_ prefix:String, _ val:Any?) {
    let tab = prefix.count < 8 ? "\t" : ""
    print(prefix + tab, val ?? val.debugDescription)
}

func debugValue(_ key:Any?, _ value:Any?) {
    if config.logLevel <= .debug {
        logAny("DEBUG.VALUE:", "\(key ?? key.debugDescription) = \(value ?? value.debugDescription)")
    }
}

func trace(_ val:Any?) { if config.logLevel <= .trace { logAny("DEBUG.TRACE:", val) } }
func debug(_ val:Any?) { if config.logLevel <= .debug { logAny("DEBUG:", val) } }
func info(_ val:Any?)  { if config.logLevel <= .info  { logAny("INFO:", val) } }
func warn(_ val:Any?)  { if config.logLevel <= .warn  { logAny("WARNING:", val) } }
func error(_ val:Any?) { if config.logLevel <= .error { logAny("ERROR:", val) } }
