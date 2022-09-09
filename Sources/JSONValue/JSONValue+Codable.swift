import Foundation

extension JSONValue: Decodable {
    public init(from decoder: Decoder) throws {
        let matchers = [decodeNil, decodeString, decodeNumber, decodeBool, decodeObject, decodeArray]

        for matcher in matchers {
            do {
                self = try matcher(decoder)
                return
            }
            catch DecodingError.typeMismatch { continue }
        }

        throw DecodingError.typeMismatch(JSONValue.self,
                                         .init(codingPath: decoder.codingPath,
                                               debugDescription: "Unknown JSON type"))
    }
}

extension JSONValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)

        case .number:
            var container = encoder.singleValueContainer()
            try container.encode(try self.asDecimal)

        case .bool(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case .object(keyValues: let keyValues):
            var container = encoder.container(keyedBy: JSONKey.self)
            for (key, value) in keyValues {
                try container.encode(value, forKey: JSONKey(key))
            }

        case .array(let values):
            var container = encoder.unkeyedContainer()
            for value in values {
                try container.encode(value)
            }

        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

// MARK: - Decode helpers

private func decodeString(decoder: Decoder) throws -> JSONValue {
    try .string(decoder.singleValueContainer().decode(String.self))
}

private func decodeNumber(decoder: Decoder) throws -> JSONValue {
    try .number(digits: decoder.singleValueContainer().decode(Decimal.self).description)
}

private func decodeBool(decoder: Decoder) throws -> JSONValue {
    try .bool(decoder.singleValueContainer().decode(Bool.self))
}

private func decodeObject(decoder: Decoder) throws -> JSONValue {
    return .object(try Dictionary(from: decoder))
}

private func decodeArray(decoder: Decoder) throws -> JSONValue {
    var array = try decoder.unkeyedContainer()
    var result: [JSONValue] = []
    if let count = array.count { result.reserveCapacity(count) }
    while !array.isAtEnd { result.append(try array.decode(JSONValue.self)) }
    return .array(result)
}

private func decodeNil(decoder: Decoder) throws -> JSONValue {
    if try decoder.singleValueContainer().decodeNil() { return .null }
    else { throw DecodingError.typeMismatch(JSONValue.self,
                                            .init(codingPath: decoder.codingPath,
                                                  debugDescription: "Did not find nil")) }
}

// MARK: - JSONKey

// Minimal version of AnyCodingKey.
private struct JSONKey: CodingKey {
    public let stringValue: String
    public init(_ string: String) { self.stringValue = string }
    public init?(stringValue: String) { self.init(stringValue) }
    public var intValue: Int? { nil }
    public init?(intValue: Int) { nil }
}
