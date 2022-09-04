import XCTest
import JSONValue

struct Customer: Decodable, Equatable {
   let personal: Personal
   let source: String
}

struct Personal: Decodable, Equatable {
    let name: String
    let customer_id: String
    let misc: JSONValue
}

extension JSONEncoder {
    func stringEncode<T>(_ value: T) throws -> String where T : Encodable {
        // JSONEncoder promises to always return UTF-8
        String(data: try self.encode(value), encoding: .utf8)!
    }
}

extension JSONDecoder {
    func stringDecode<T>(_ type: T.Type, from string: String) throws -> T where T : Decodable {
        try JSONDecoder().decode(T.self, from: Data(string.utf8))
    }
}


final class JSONValueCodableTests: XCTestCase {
    func testStringEncode() throws {
        let value = JSONValue("test")
        let result = try JSONEncoder().stringEncode(value)
        let expected = "\"test\""

        XCTAssertEqual(result, expected)
    }

    func testStringDecode() throws {
        let json = "\"test\""
        let result = try JSONDecoder().stringDecode(JSONValue.self, from: json)
        let expectedValue = "test"
        let expectedJSON = JSONValue(expectedValue)

        XCTAssertEqual(result, expectedJSON)
        XCTAssertEqual(try result.stringValue, expectedValue)
    }

    func testIntEncode() throws {
        let value = JSONValue(1)
        let result = try JSONEncoder().stringEncode(value)
        let expected = "1"

        XCTAssertEqual(result, expected)
    }

    func testIntDecode() throws {
        let json = "1"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from: json)
        let expectedValue = 1

        XCTAssertEqual(result, JSONValue(expectedValue))
        XCTAssertEqual(try result.intValue, expectedValue)
    }

    func testDoubleEncode() throws {
        let value = JSONValue(1.1)
        let result = try JSONEncoder().stringEncode(value)
        let expected = "1.1"

        XCTAssertEqual(result, expected)
    }

    func testDoubleDecode() throws {
        let json = "1.1"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from:json)
        let expectedValue = 1.1

        XCTAssertEqual(result, JSONValue(expectedValue))
        XCTAssertEqual(try result.doubleValue, expectedValue)
    }

    func testUInt32Encode() throws {
        let value = JSONValue(1 as UInt32)
        let result = try JSONEncoder().stringEncode(value)
        let expected = "1"

        XCTAssertEqual(result, expected)
    }

    func testUInt32Decode() throws {
        let json = "1"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from:json)
        let expectedValue = 1 as UInt32

        XCTAssertEqual(result, JSONValue(expectedValue))
        XCTAssertEqual(try result.uint32Value, expectedValue)
    }

    func testBoolEncode() throws {
        let value = JSONValue(true)
        let result = try JSONEncoder().stringEncode(value)
        let expected = "true"

        XCTAssertEqual(result, expected)
    }

    func testBoolDecode() throws {
        let json = "true"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from:json)
        let expectedValue = true

        XCTAssertEqual(result, JSONValue(expectedValue))
        XCTAssertEqual(try result.boolValue, expectedValue)
    }

    func testObjectEncode() throws {
        let value: JSONValue = ["name": "Bob", "age": 43]
        let result = try JSONEncoder().stringEncode(value)
        let expected = "{\"name\":\"Bob\",\"age\":43}"

        XCTAssertEqual(result, expected)
    }

    func testObjectDecode() throws {
        let json = "{\"name\":\"Bob\",\"age\":43}"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from:json)
        let expectedValue = ["name": "Bob", "age": 43] as JSONValue

        XCTAssertEqual(result, JSONValue(expectedValue))
        XCTAssertEqual(result, expectedValue)
    }

    func testArrayEncode() throws {
        let value = JSONValue([1,2,3])
        let result = try JSONEncoder().stringEncode(value)
        let expected = "[1,2,3]"

        XCTAssertEqual(result, expected)
    }

    func testArrayDecode() throws {
        let json = "[1,2,3]"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from:json)
        let expectedValue = [1,2,3] as [JSONValue]

        XCTAssertEqual(result, JSONValue(expectedValue))
        XCTAssertEqual(try result.arrayValue(), expectedValue)
    }

    func testNullEncode() throws {
        let value = JSONValue.null
        let result = try JSONEncoder().stringEncode(value)
        let expected = "null"

        XCTAssertEqual(result, expected)
    }

    func testNullDecode() throws {
        let json = "null"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from:json)
        let expectedValue = JSONValue.null

        XCTAssertEqual(result, expectedValue)
        XCTAssert(expectedValue.isNull)
    }

    func testNilEncode() throws {
        let value = JSONValue(nil)
        let result = try JSONEncoder().stringEncode(value)
        let expected = "null"

        XCTAssertEqual(result, expected)
    }

    func testNilDecode() throws {
        let json = "null"
        let result = try JSONDecoder().stringDecode(JSONValue.self, from:json)
        let expectedValue = JSONValue(nil)

        XCTAssertEqual(result, expectedValue)
        XCTAssert(expectedValue.isNull)
    }

    func testNestedDecode() throws {
        let json = Data("""
        {
            "personal": {
                "name": "John Doe",
                "customer_id": "1234",
                "misc": {
                    "active": true,
                    "addons": {
                        "country": "USA",
                        "state": "Michigan"
                    }
                }
            },
            "source": "main"
        }
        """.utf8)

        let misc: JSONValue = [
            "active": true,
            "addons": [
                "country": "USA",
                "state": "Michigan"
            ]
        ]

        let expected = Customer(personal: Personal(name: "John Doe",
                                                   customer_id: "1234",
                                                   misc: misc), source: "main")

        let parsed = try JSONDecoder().decode(Customer.self, from: json)
        XCTAssertEqual(parsed, expected)
    }

}
