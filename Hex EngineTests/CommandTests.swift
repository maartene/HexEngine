//
//  CommandTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 19/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class CommandTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCommandTest() {
        struct TestCommand: Command {
            var title = "Test Command"
            var owner: Commander
        }
        
        struct TestCommander: Commander {
            var id: Int
            var position: AxialCoord
        }
        
        let commander = TestCommander(id: 14, position: AxialCoord(q: 23, r: 12))
        let command = TestCommand(owner: commander)
        let world = World(width: 100, height: 100, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        XCTAssertNotNil(world.executeCommand(command))
    }
    
    func testMutatingCommandTest() {
        struct TestCommand: Command {
            var title = "Mutating Command"
            var owner: Commander
            
            func execute(in world: World) throws -> World {
                var changedWorld = world
                // flip a single tile from "enterable" to "blocks movement" or vice versa
                print("Before: Tile at 0,0: \(world.hexMap[0,0])")
                changedWorld.hexMap[0,0] = world.hexMap[0,0].blocksMovement ? Tile.Forest : Tile.Water
                print("After: Tile at 0,0: \(changedWorld.hexMap[0,0])")
                return changedWorld
            }
        }
        
        struct TestCommander: Commander {
            var id: Int
            var position: AxialCoord
        }
        
        let commander = TestCommander(id: 14, position: AxialCoord(q: 23, r: 12))
        let command = TestCommand(owner: commander)
        let world = World(width: 100, height: 100, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        XCTAssertNotEqual(world.hexMap[0,0], world.executeCommand(command).hexMap[0,0])
    }
    
    func testAddCityCommand() {
        struct TestCommander: Commander {
            var id: Int
            var position: AxialCoord
        }
        
        let commander = TestCommander(id: 14, position: AxialCoord(q: 23, r: 12))
        var world = World(width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        world.hexMap[commander.position] = .Grass
        
        let command = BuildCityCommand(owner: commander)
        XCTAssertNil(world.getCityAt(commander.position))
        let newWorld = world.executeCommand(command)
        let city = newWorld.getCityAt(commander.position)
        print(city?.name ?? "no city here")
        XCTAssertNotNil(city)
    }
}
