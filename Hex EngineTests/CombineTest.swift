//
//  CombineTest.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 04/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
import Combine
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

    func testCombinePerformanceWhenSavingUnitChangesExample() throws {
        // This is an example of a performance test case.
        for _ in 0 ..< 100 {
            let unit = Unit.Rabbit(owningPlayer: world.currentPlayer!.id, startPosition: world.hexMap.getTileCoordinates().randomElement()!)
            world.addUnit(unit)
        }
        
        var cancellables = Set<AnyCancellable>()
        
        var count = 0
        world.$units.sink(receiveValue: { units in
            for _ in units.values {
                // do something
                count += 1
            }
        }).store(in: &cancellables)
        
        var pass = 0
        self.measure {
            pass += 1
            print("Pass: \(pass)")
            // Put the code you want to measure the time of here.
            var changedUnits = world.units
            for unit in changedUnits.values {
                var changedUnit = unit
                changedUnit.position = world.hexMap.getTileCoordinates().randomElement() ?? AxialCoord.zero
                changedUnits[changedUnit.id] = changedUnit
            }
            world.units = changedUnits
        }
        print("In total, received \(count) units.")
        XCTAssertGreaterThan(count, 0)
    }
    
    func testCombinePerformanceWithDirectUpdatesExample() throws {
        // This is an example of a performance test case.
        for _ in 0 ..< 100 {
            let unit = Unit.Rabbit(owningPlayer: world.currentPlayer!.id, startPosition: world.hexMap.getTileCoordinates().randomElement()!)
            world.addUnit(unit)
        }
        
        var cancellables = Set<AnyCancellable>()
        
        var count = 0
        world.$units.sink(receiveValue: { units in
            for _ in units.values {
                // do something
                count += 1
            }
        }).store(in: &cancellables)
        
        var pass = 0
        self.measure {
            pass += 1
            print("Pass: \(pass)")
            // Put the code you want to measure the time of here.
            for unit in world.allUnits {
                var changedUnit = unit
                changedUnit.position = world.hexMap.getTileCoordinates().randomElement() ?? AxialCoord.zero
                world.replace(changedUnit)
            }
        }
        print("In total, received \(count) units.")
        XCTAssertGreaterThan(count, 0)
    }

}
