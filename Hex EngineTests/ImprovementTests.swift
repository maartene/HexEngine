//
//  ImprovementTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 12/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class ImprovementTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImprovementBringsYields() throws {
        var world = World(playerCount: 1, width: 10, height: 10, hexMapFactory: getTestMap(width:height:))
        var city = City(owningPlayer: world.currentPlayer!.id, name: "Test City", position: AxialCoord.zero)
        world.addCity(city)
        world = world.nextTurn()
        city = try world.getCityWithID(city.id)
        let originalYield = city.yield
        
        let improvement = Improvement.getProtype(title: "Granary", for: city.id)
        
        city.buildings.append(improvement)
        world.replace(city)
        world = world.nextTurn()
        
        let newYield = try world.getCityWithID(city.id).yield
        XCTAssertGreaterThan(newYield.food, originalYield.food, " food")
    }
    
    
}
