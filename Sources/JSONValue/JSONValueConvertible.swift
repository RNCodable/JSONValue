import Foundation

extension JSONValue {
    public init(_ convertible: LosslessJSONConvertible) { self = convertible.asJSON() }
    public init(_ convertible: JSONConvertible) throws { self = try convertible.asJSON() }
}

// JSONConvertible

public protocol JSONConvertible {
    func asJSON() throws -> JSONValue
}

public protocol LosslessJSONConvertible: JSONConvertible {
    func asJSON() -> JSONValue
}

extension String: LosslessJSONConvertible {
    public func asJSON() -> JSONValue { .string(self) }
}

extension BinaryInteger {
    public func asJSON() -> JSONValue { .number(digits: "\(self)") }
}

extension Int: LosslessJSONConvertible {}
extension Int8: LosslessJSONConvertible {}
extension Int16: LosslessJSONConvertible {}
extension Int32: LosslessJSONConvertible {}
extension Int64: LosslessJSONConvertible {}
extension UInt: LosslessJSONConvertible {}
extension UInt8: LosslessJSONConvertible {}
extension UInt16: LosslessJSONConvertible {}
extension UInt32: LosslessJSONConvertible {}
extension UInt64: LosslessJSONConvertible {}

extension BinaryFloatingPoint {
    public func asJSON() -> JSONValue { .number(digits: "\(self)") }
}

extension Float: LosslessJSONConvertible {}
extension Double: LosslessJSONConvertible {}

extension Decimal: LosslessJSONConvertible {
    public func asJSON() -> JSONValue {
        var decimal = self
        return .number(digits: NSDecimalString(&decimal, nil))
    }
}

extension JSONValue: LosslessJSONConvertible {
    public func asJSON() -> JSONValue { self }
}

extension Bool: LosslessJSONConvertible {
    public func asJSON() -> JSONValue { .bool(self) }
}

extension Sequence where Element: LosslessJSONConvertible {
    public func asJSON() -> JSONValue { .array(self.map { $0.asJSON() }) }
}

extension Sequence where Element: JSONConvertible {
    public func asJSON() throws -> JSONValue { .array(try self.map { try $0.asJSON() }) }
}

extension NSArray: JSONConvertible {
    public func asJSON() throws -> JSONValue {
        .array(try self.map {
            guard let value = $0 as? JSONConvertible else { throw JSONValue.Error.typeMismatch }
            return try value.asJSON()
        })
    }
}

extension NSDictionary: JSONConvertible {
    public func asJSON() throws -> JSONValue {
        guard let dict = self as? [String: JSONConvertible] else {
            throw JSONValue.Error.typeMismatch
        }
        return try dict.asJSON()
    }
}

extension Array: LosslessJSONConvertible where Element: LosslessJSONConvertible {}
extension Array: JSONConvertible where Element: JSONConvertible {}

public extension Sequence where Element == (key: String, value: LosslessJSONConvertible) {
    func asJSON() -> JSONValue {
        return .object(Dictionary(self.map { ($0.key, $0.value.asJSON()) },
                                  uniquingKeysWith: { (_, last) in last }))
    }
}

public extension Sequence where Element == (key: String, value: JSONConvertible) {
    func asJSON() throws -> JSONValue {
        return .object(Dictionary(try self.map { ($0.key, try $0.value.asJSON()) },
                                  uniquingKeysWith: { (_, last) in last }))
    }
}

public extension Dictionary where Key == String, Value: LosslessJSONConvertible {
    func asJSON() -> JSONValue {
        return .object(self.mapValues { $0.asJSON() })
    }
}

public extension Dictionary where Key == String, Value: JSONConvertible {
    func asJSON() throws -> JSONValue {
        return .object(try self.mapValues { try $0.asJSON() })
    }
}
