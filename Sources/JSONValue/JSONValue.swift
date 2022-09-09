public enum JSONValue {
    case string(String)
    case number(digits: String)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null
    public enum Error: Swift.Error {
        case typeMismatch
        case missingValue
    }
}

// NOTE: It's tempting to make this LosslessStringConvertible, but that would conflict with the JSON(String) initializer
extension JSONValue: CustomStringConvertible, Hashable {
    // The output of `description` is legal Swift that would reconstruct the JSONValue.
    public var description: String {
        switch self {
        case .string(let string): return string.debugDescription
        case .number(let digits): return digits.digitsDescription
        case .bool(let value): return value ? "true" : "false"
        case .object(let object):
            if object.isEmpty {
                return "[:]"
            } else {
                return "[" +
                object
                    .sorted(by: { $0.key < $1.key })
                    .map { "\($0.key.debugDescription): \($0.value)" }.joined(separator: ", ") +
                "]"
            }
        case .array(let values):
            return "[" + values.map(\.description).joined(separator: ", ") + "]"
        case .null: return "nil"
        }
    }
}

internal extension String {
    var digitsDescription: String {
        let interpreted = "\(self)"
        if let int = Int(interpreted), "\(int)" == interpreted {
            return interpreted
        }
        if let double = Double(interpreted), "\(double)" == interpreted {
            return interpreted
        }
        return """
                .digits("\(self)")
                """
    }
}
