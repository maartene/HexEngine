//
//  CombineTest.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 04/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class CombineTest: XCTestCase {

    var world: World!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        world = World(playerCount: 1, width: 200, height: 100, hexMapFactory: getTestMap(width:height:))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        for _ in 0 ..< 10 {
            let unit = Unit.Rabbit(owningPlayer: world.currentPlayer!.id, startPosition: world.hexMap.getTileCoordinates().randomElement()!)
            world.addUnit(unit)
            world.executeCommand(EnableAutoExploreCommand(ownerID: unit.id))
        }
        
        self.measure {
            // Put the code you want to measure the time of here.
            world.executeCommand(NextTurnCommand(ownerID: world.currentPlayer!.id))
        }
    }

}
