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

    /*func testCommandTest() {
        struct TestCommand: Command {
            var title = "Test Command"
            var ownerID: UUID
        }
        
        struct TestCommander: Commander {
            var owningPlayerID: UUID
            var id: UUID
            var position: AxialCoord
        }
        let world = World(playerCount: 1, width: 100, height: 100, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        
        let commander = TestCommander(owningPlayerID: world.currentPlayer!.id, id: UUID(), position: AxialCoord(q: 23, r: 12))
        let command = TestCommand(ownerID: commander.id)
        
        XCTAssertNotNil(world.executeCommand(command))
    }*/
    
    /*func testMutatingCommandTest() {
        struct TestCommand: Command {
            var title = "Mutating Command"
            var ownerID: UUID
            
            func execute(in world: World) throws {
                // flip a single tile from "enterable" to "blocks movement" or vice versa
                print("Before: Tile at 0,0: \(world.hexMap[0,0])")
                world.hexMap[0,0] = Tile.defaultCostsToEnter[world.hexMap[0,0], default: -1] < 0 ? Tile.Forest : Tile.Water
                print("After: Tile at 0,0: \(world.hexMap[0,0])")
                return
            }
        }
        
        struct TestCommander: Commander {
            var owningPlayerID: UUID
            var id: UUID
            var position: AxialCoord
        }
        let world = World(playerCount: 1, width: 100, height: 100, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        
        let commander = TestCommander(owningPlayerID: world.currentPlayer!.id, id: UUID(), position: AxialCoord(q: 23, r: 12))
        let command = TestCommand(ownerID: commander.id)
        
        let oldTile = world.hexMap[0,0]
        world.executeCommand(command)
        XCTAssertNotEqual(oldTile, world.hexMap[0,0])
    }*/
    
    func testAddCityCommand() {
        //Int, name: String, movement: Int = 2, startPosition: AxialCoord = AxialCoord.zero) {
        let world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        let commander = Unit(owningPlayer: world.currentPlayer!.id, name: "Rabbit", startPosition: AxialCoord(q: 23, r: 12))
        
        world.addUnit(commander)
        world.hexMap[commander.position] = .Grass
        
        let command = FoundCityCommand(ownerID: commander.id)
        XCTAssertNil(world.getCityAt(commander.position))
        world.executeCommand(command)
        let city = world.getCityAt(commander.position)
        print(city?.name ?? "no city here")
        XCTAssertNotNil(city)
    }
    
    func testBuilderCommand() {
        let world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        let coord = AxialCoord(q: 23, r: 12)
        let newCity = City(owningPlayer: world.currentPlayer!.id, name: "Test city", position: coord)
        world.addCity(newCity)
        
        guard var city = world.getCityAt(coord) else {
            XCTAssert(false)
            return
        }
        
        let command = city.possibleCommands[0]
        
        // note: this is a new city. 
        world.executeCommand(command)
        city = world.getCityAt(coord)!
        let buildComponent = city.getComponent(BuildComponent.self)
        XCTAssertGreaterThan(buildComponent?.buildQueue.count ?? -1, 0)
        print("City at \(coord): \(world.getCityAt(coord)?.name ?? "no city here"). build queue there: \(String(describing: buildComponent?.buildQueue))")
        
        // now to get this city in the world again.
        world.replace(city)
        
        XCTAssertGreaterThan(world.getCityAt(coord)?.getComponent(BuildComponent.self)?.buildQueue.count ?? 0, 0)
    }
    
    func testCreateUnitTest() {
        let world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        let coord = AxialCoord(q: 23, r: 12)
        let newCity = City(owningPlayer: world.currentPlayer!.id, name: "Test city", position: coord)
        world.addCity(newCity)
        
        guard var city = world.getCityAt(coord) else {
            XCTAssert(false)
            return
        }
        
        let command = city.possibleCommands[0]
        
        // note: this is a new city.
        world.executeCommand(command)
        city = world.getCityAt(coord)!
        let buildComponent = city.getComponent(BuildComponent.self)
        XCTAssertGreaterThan(buildComponent?.buildQueue.count ?? 0, 0)
        print("City at \(coord): \(world.getCityAt(coord)?.name ?? "no city here"). build queue there: \(String(describing: buildComponent?.buildQueue))")
        
        // now to get this city in the world again.
        world.replace(city)
        
        XCTAssertGreaterThan(world.getCityAt(coord)?.getComponent(BuildComponent.self)?.buildQueue.count ?? 0, 0)
        
        // there should no bunny on the coordinates of the city
        XCTAssertEqual(world.getUnitsOnTile(coord).count, 0)
        
        world.nextTurn()
        world.nextTurn()
        
        // there should now be a bunny on coordinates of the city
        XCTAssertEqual(world.getUnitsOnTile(coord).count, 1)
        
        //let uuid = UUID()
    }
}
