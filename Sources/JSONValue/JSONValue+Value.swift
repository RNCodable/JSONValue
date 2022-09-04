#if canImport(Foundation)
import Foundation
#endif

// String
extension JSONValue {
    public var stringValue: String {
        get throws {
            guard case let .string(value) = self else { throw Error.typeMismatch }
            return value
        }
    }
}

// Number
extension JSONValue {
    // Convenience constructor from digits.
    public static func digits(_ digits: String) -> Self {
        .number(digits: digits)
    }

    public var digits: String {
        get throws {
            guard case let .number(digits) = self else { throw Error.typeMismatch }
            return digits
        }
    }

    private func _numberValue<T: LosslessStringConvertible>() throws -> T {
        guard let value = T(try digits) else { throw Error.typeMismatch }
        return value
    }

    public var intValue: Int { get throws { try _numberValue() } }
    public var doubleValue: Double { get throws { try _numberValue() } }
    public var floatValue: Float { get throws { try _numberValue() } }

    public var uintValue: UInt { get throws { try _numberValue() } }
    public var uint8Value: UInt8 { get throws { try _numberValue() } }
    public var uint16Value: UInt16 { get throws { try _numberValue() } }
    public var uint32Value: UInt32 { get throws { try _numberValue() } }
    public var uint64Value: UInt64 { get throws { try _numberValue() } }

    public var int8Value: Int8 { get throws { try _numberValue() } }
    public var int16Value: Int16 { get throws { try _numberValue() } }
    public var int32Value: Int32 { get throws { try _numberValue() } }
    public var int64Value: Int64 { get throws { try _numberValue() } }

    #if canImport(Foundation)
    public var decimalValue: Decimal {
        get throws {
            guard let value = Decimal(string: try digits) else { throw Error.typeMismatch }
            return value
        }
    }
    #endif
}

// Bool
extension JSONValue {
    public var boolValue: Bool {
        get throws {
            guard case let .bool(value) = self else { throw Error.typeMismatch }
            return value
        }
    }
}

// Object
extension JSONValue {
    public var keyValues: JSONKeyValues {
        get throws {
            guard case let .object(keyValues) = self else { throw Error.typeMismatch }
            return keyValues
        }
    }

    // Uniques keys using last value by default. This allows overrides.
    // Compare to ``value(for:)``
    public var dictionaryValue: [String: JSONValue] {
        get throws {
            try dictionaryValue(uniquingKeysWith: { _, last in last })
        }
    }

    public func dictionaryValue(uniquingKeysWith: (JSONValue, JSONValue) -> JSONValue)
    throws -> [String: JSONValue] {
        Dictionary(try keyValues, uniquingKeysWith: uniquingKeysWith)
    }

    // Returns first value matching key.
    public func value(for key: String) throws -> JSONValue {
        guard let result = try keyValues.first(where: { $0.key == key })?.value else {
            throw Error.missingValue
        }
        return result
    }

    public func values(for key: String) throws -> [JSONValue] {
        try keyValues.filter({ $0.key == key }).map(\.value)
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
