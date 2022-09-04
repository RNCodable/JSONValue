import Foundation

// String
extension JSONValue {
    public var asString: String {
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

    public var asInt: Int { get throws { try _numberValue() } }
    public var asDouble: Double { get throws { try _numberValue() } }
    public var asFloat: Float { get throws { try _numberValue() } }

    public var asUInt: UInt { get throws { try _numberValue() } }
    public var asUInt8: UInt8 { get throws { try _numberValue() } }
    public var asUInt16: UInt16 { get throws { try _numberValue() } }
    public var asUInt32: UInt32 { get throws { try _numberValue() } }
    public var asUInt64: UInt64 { get throws { try _numberValue() } }

    public var asInt8: Int8 { get throws { try _numberValue() } }
    public var asInt16: Int16 { get throws { try _numberValue() } }
    public var asInt32: Int32 { get throws { try _numberValue() } }
    public var asInt64: Int64 { get throws { try _numberValue() } }

    public var asDecimal: Decimal {
        get throws {
            guard let value = Decimal(string: try digits) else { throw Error.typeMismatch }
            return value
        }
    }
}

// Bool
extension JSONValue {
    public var asBool: Bool {
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
    public var asDictionary: [String: JSONValue] {
        get throws {
            try asDictionary(uniquingKeysWith: { _, last in last })
        }
    }

    public func asDictionary(uniquingKeysWith: (JSONValue, JSONValue) -> JSONValue)
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
    public var asArray: [JSONValue] {
        get throws {
            guard case let .array(array) = self else { throw Error.typeMismatch }
            return array
        }
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
        let array = try self.asArray
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
