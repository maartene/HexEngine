//
//  EntityTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 24/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class EntityTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReplaceComponent() throws {
        var unit = Rabbit(owningPlayer: UUID(), startPosition: AxialCoord.zero)
        let swimmingComponent = MovementComponent(ownerID: unit.id, movementCosts: [.Water : 1])
        
        XCTAssertEqual(unit.getComponent(MovementComponent.self)?.movementCosts[.Water], -1)
        
        unit.replaceComponent(component: swimmingComponent)
        
        XCTAssertEqual(unit.getComponent(MovementComponent.self)?.movementCosts[.Water], 1)
    }
    
    func testGetComponent() throws {
        let unit = Rabbit(owningPlayer: UUID(), startPosition: AxialCoord.zero)
        let movementComponent = unit.getComponent(MovementComponent.self)
        XCTAssertNotNil(movementComponent)
    }
    
    func testPossibleCommands() throws {
        let unit = Rabbit(owningPlayer: UUID(), startPosition: AxialCoord.zero)
        XCTAssertGreaterThan(unit.possibleCommands.count, 0)
        
        var total = 0
        for component in unit.components {
            total += component.possibleCommands.count
        }
        XCTAssertEqual(unit.possibleCommands.count, total)
    }
}
