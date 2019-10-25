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
            var ownerID: UUID
        }
        
        struct TestCommander: Commander {
            var id: UUID
            var position: AxialCoord
        }
        
        let commander = TestCommander(id: UUID(), position: AxialCoord(q: 23, r: 12))
        let command = TestCommand(ownerID: commander.id)
        let world = World(width: 100, height: 100, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        XCTAssertNotNil(world.executeCommand(command))
    }
    
    func testMutatingCommandTest() {
        struct TestCommand: Command {
            var title = "Mutating Command"
            var ownerID: UUID
            
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
            var id: UUID
            var position: AxialCoord
        }
        
        let commander = TestCommander(id: UUID(), position: AxialCoord(q: 23, r: 12))
        let command = TestCommand(ownerID: commander.id)
        let world = World(width: 100, height: 100, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        XCTAssertNotEqual(world.hexMap[0,0], world.executeCommand(command).hexMap[0,0])
    }
    
    // FIXME: this fails because the new commander is never integrated into the world.
    func testAddCityCommand() {
        //Int, name: String, movement: Int = 2, startPosition: AxialCoord = AxialCoord.zero) {
        let commander = Unit(name: "Rabbit", startPosition: AxialCoord(q: 23, r: 12))
        var world = World(width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        world.addUnit(commander)
        world.hexMap[commander.position] = .Grass
        
        let command = BuildCityCommand(ownerID: commander.id)
        XCTAssertNil(world.getCityAt(commander.position))
        let newWorld = world.executeCommand(command)
        let city = newWorld.getCityAt(commander.position)
        print(city?.name ?? "no city here")
        XCTAssertNotNil(city)
    }
    
    func testBuilderCommand() {
        var world = World(width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        let coord = AxialCoord(q: 23, r: 12)
        let newCity = City(name: "Test city", position: coord)
        world.addCity(newCity)
        
        guard var city = world.getCityAt(coord) else {
            XCTAssert(false)
            return
        }
        
        let command = city.possibleCommands[0]
        
        // note: this is a new city. 
        city.buildQueue.append(command)
        print(city)
        XCTAssertGreaterThan(city.buildQueue.count, 0)
        print("City at \(coord): \(world.getCityAt(coord)?.name ?? "no city here"). build queue there: \(world.getCityAt(coord)?.buildQueue)")
        
        // now to get this city in the world again.
        world.replace(city)
        
        XCTAssertGreaterThan(world.getCityAt(coord)?.buildQueue.count ?? 0, 0)
    }
    
    func testCreateUnitTest() {
        var world = World(width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        let coord = AxialCoord(q: 23, r: 12)
        let newCity = City(name: "Test city", position: coord)
        world.addCity(newCity)
        
        guard var city = world.getCityAt(coord) else {
            XCTAssert(false)
            return
        }
        
        let command = city.possibleCommands[0]
        
        // note: this is a new city.
        city.buildQueue.append(command)
        print(city)
        XCTAssertGreaterThan(city.buildQueue.count, 0)
        print("City at \(coord): \(world.getCityAt(coord)?.name ?? "no city here"). build queue there: \(world.getCityAt(coord)?.buildQueue)")
        
        // now to get this city in the world again.
        world.replace(city)
        
        XCTAssertGreaterThan(world.getCityAt(coord)?.buildQueue.count ?? 0, 0)
        
        // there should no bunny on the coordinates of the city
        XCTAssertEqual(world.getUnitsOnTile(coord).count, 0)
        
        world = world.nextTurn()
        world = world.nextTurn()
        
        // there should now be a bunny on coordinates of the city
        XCTAssertEqual(world.getUnitsOnTile(coord).count, 1)
        
        //let uuid = UUID()
    }
}
