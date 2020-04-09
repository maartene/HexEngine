//
//  UnitTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 24/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class UnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func _testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func _testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testUnitCodable() throws {
        let unit = Hex_Engine.Unit(owningPlayer: UUID(), name: "testUnit\(Int.random(in: 0...10000))", visibility: Int.random(in: 1...10), productionRequired: 40, startPosition: AxialCoord(q: Int.random(in: -100...100), r: Int.random(in: -100...100)))
        
        let encoder = JSONEncoder()
        let encodedUnit = try encoder.encode(unit)
        
        let decoder = JSONDecoder()
        let decodedUnit = try decoder.decode(Hex_Engine.Unit.self, from: encodedUnit)
        
        XCTAssertEqual(decodedUnit.id, unit.id)
        XCTAssertEqual(decodedUnit.name, unit.name)
        XCTAssertEqual(decodedUnit.owningPlayerID, unit.owningPlayerID)
        XCTAssertEqual(decodedUnit.position, unit.position)
        XCTAssertEqual(decodedUnit.visibility, unit.visibility)
    }

}
