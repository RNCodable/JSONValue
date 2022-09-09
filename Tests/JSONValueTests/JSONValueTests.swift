//
//  JSONValueTests.swift
//  
//
//  Created by Rob Napier on 9/4/22.
//

import XCTest
import JSONValue

final class JSONValueDescriptionTests: XCTestCase {
    func testString() throws {
        let value = JSONValue.string("abc")
        XCTAssertEqual(value.description, "\"abc\"")
    }

    func testInt() throws {
        let value = JSONValue.number(digits: "123")
        XCTAssertEqual(value.description, "123")
    }

    func testFloat() throws {
        let value = JSONValue.number(digits: "1.23")
        XCTAssertEqual(value.description, "1.23")
    }

    func testBigInt() throws {
        let value = JSONValue.number(digits: "36893488147419103232") // 2^65
        XCTAssertEqual(value.description, ".digits(\"36893488147419103232\")")
    }

    func testTrue() throws {
        let value = JSONValue.bool(true)
        XCTAssertEqual(value.description, "true")
    }

    func testFalse() throws {
        let value = JSONValue.bool(false)
        XCTAssertEqual(value.description, "false")
    }

    func testObject() throws {
        let value: JSONValue = [
            "string": "def",
            "int": 123,
            "bool": true,
            "object": ["nested": "123"],
            "array": [1, 2, 3],
            "null": nil
            ]
        XCTAssertEqual(value.description, #"""
            ["array": [1, 2, 3], "bool": true, "int": 123, "null": nil, "object": ["nested": "123"], "string": "def"]
            """#)
    }

    func testEmptyObject() throws {
        let value: JSONValue = [:]
        XCTAssertEqual(value.description, "[:]")
    }

    func testArray() throws {
        let value: JSONValue = ["string", 123, true, ["key": "value"], ["nested"], nil]
        XCTAssertEqual(value.description, #"""
            ["string", 123, true, ["key": "value"], ["nested"], nil]
            """#)
    }

    func testEmptyArray() throws {
        let value: JSONValue = []
        XCTAssertEqual(value.description, "[]")
    }

    func testNull() throws {
        let value: JSONValue = nil
        XCTAssertEqual(value.description, "nil")
    }
}
