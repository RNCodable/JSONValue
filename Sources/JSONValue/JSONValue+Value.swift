#if canImport(Foundation)
import Foundation
#endif

// String
extension JSONValue {
    public func stringValue() throws -> String {
        guard case let .string(value) = self else { throw Error.typeMismatch }
        return value
    }
}

// Number
extension JSONValue {
    // Convenience constructor from digits.
    public static func digits(_ digits: String) -> Self {
        .number(digits: digits)
    }

    public func digits() throws -> String {
        guard case let .number(digits) = self else { throw Error.typeMismatch }
        return digits
    }

    private func _numberValue<T: LosslessStringConvertible>() throws -> T {
        guard let value = T(try digits()) else { throw Error.typeMismatch }
        return value
    }

    public func intValue() throws -> Int { try _numberValue() }
    public func doubleValue() throws -> Double { try _numberValue() }
    public func floatValue() throws -> Float { try _numberValue() }

    public func uintValue() throws -> UInt { try _numberValue() }
    public func uint8Value() throws -> UInt8 { try _numberValue() }
    public func uint16Value() throws -> UInt16 { try _numberValue() }
    public func uint32Value() throws -> UInt32 { try _numberValue() }
    public func uint64Value() throws -> UInt64 { try _numberValue() }

    public func int8Value() throws -> Int8 { try _numberValue() }
    public func int16Value() throws -> Int16 { try _numberValue() }
    public func int32Value() throws -> Int32 { try _numberValue() }
    public func int64Value() throws -> Int64 { try _numberValue() }

    #if canImport(Foundation)
    public func decimalValue() throws -> Decimal {
        guard let value = Decimal(string: try digits()) else { throw Error.typeMismatch }
        return value
    }
    #endif
}

// Bool
extension JSONValue {
    public func boolValue() throws -> Bool {
        guard case let .bool(value) = self else { throw Error.typeMismatch }
        return value
    }
}

// Object
extension JSONValue {
    public func keyValues() throws -> JSONKeyValues {
        guard case let .object(keyValues) = self else { throw Error.typeMismatch }
        return keyValues
    }

    // Uniques keys using last value by default. This allows overrides.
    public func dictionaryValue(uniquingKeysWith: (JSONValue, JSONValue) -> JSONValue = { _, last in last })
    throws -> [String: JSONValue] {
        Dictionary(try keyValues(), uniquingKeysWith: uniquingKeysWith)
    }

    // Returns first value matching key.
    public func value(for key: String) throws -> JSONValue {
        guard let result = try keyValues().first(where: { $0.key == key })?.value else {
            throw Error.missingValue
        }
        return result
    }

    public func values(for key: String) throws -> [JSONValue] {
        try keyValues().filter({ $0.key == key }).map(\.value)
    }

    public subscript(_ key: String) -> JSONValue {
        get throws { try value(for: key) }
    }

    // TODO: Add setters?
}

// Array
extension JSONValue {
    public func arrayValue() throws -> [JSONValue] {
        guard case let .array(array) = self else { throw Error.typeMismatch }
        return array
    }

    public var count: Int {
        get throws {
            switch self {
            case let .array(array): return array.count
            case let .object(object): return object.count
            default: throw Error.typeMismatch
            }
        }
    }

    public func value(at index: Int) throws -> JSONValue {
        let array = try arrayValue()
        guard array.indices.contains(index) else { throw Error.missingValue }
        return array[index]
    }

    public subscript(_ index: Int) -> JSONValue {
        get throws { try value(at: index) }
    }

    // TODO: Add setters?
}

// Null
extension JSONValue {
    public var isNull: Bool { if case .null = self { return true } else { return false } }
}
