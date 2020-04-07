//
//  WorldTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 19/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import XCTest
import SpriteKit
@testable import Hex_Engine

class WorldTests: XCTestCase {

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
    
    func testCalculateVisibilityPerformanceTest() {
        // Rebuilding the pathfinding graph is notoriously expensive
        // This tests how long it takes to rebuild the pathfinding graph for a Civ VI HUGE map (106x66 tiles)
        //let world = World(playerCount: 1, width: 106, height: 66, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        var world = World(playerCount: 1, width: 212, height: 132, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        
        var tileSKSpriteNodeMap = [AxialCoord: SKSpriteNode]()
        for coord in world.hexMap.getTileCoordinates() {
            tileSKSpriteNodeMap[coord] = SKSpriteNode(imageNamed: "unknown")
        }
        
        var tileTextureMap = [Tile: SKTexture]()
        tileTextureMap[.Forest] = SKTexture(imageNamed: "grass_13")
        tileTextureMap[.Grass] = SKTexture(imageNamed: "grass_05")
        tileTextureMap[.Mountain] = SKTexture(imageNamed: "dirt_18")
        tileTextureMap[.Sand] = SKTexture(imageNamed: "sand_07")
        tileTextureMap[.Water] = SKTexture(imageNamed: "water")
        
        func getTextureForTile(tile: Tile) -> SKTexture {
            return tileTextureMap[tile] ?? SKTexture()
        }
        
        func showHideTiles(visibilityMap: [AxialCoord: TileVisibility]) {
            print("showHideTiles \(tileSKSpriteNodeMap.keys.count)")
            for coord in tileSKSpriteNodeMap.keys {
                guard let sprite = tileSKSpriteNodeMap[coord] else {
                    continue
                }
                
                let tile = world.hexMap[coord]
                
                if (visibilityMap[coord] ?? .unvisited) == .visible {
                    sprite.alpha = 1
                    sprite.texture = getTextureForTile(tile: tile)
                } else if (visibilityMap[coord] ?? .unvisited) == .visited {
                    sprite.alpha = 0.5
                    sprite.texture = getTextureForTile(tile: tile)
                }
            }
        }
        
        for i in 0 ..< 100 {
            world.addCity(City(owningPlayer: world.playerTurnSequence[0], name: "Test \(i)", position: world.hexMap.getTileCoordinates().randomElement()!))
            world.addUnit(Unit.Rabbit(owningPlayer: world.playerTurnSequence[0], startPosition: world.hexMap.getTileCoordinates().randomElement()!))
        }
        
        var pass = 1
        self.measure {
            // Put the code you want to measure the time of here.
            showHideTiles(visibilityMap: world.currentPlayer!.calculateVisibility(in: world).visibilityMap)
            print("testCalculateVisibilityPerformanceTest pass: \(pass) complete.")
            pass += 1
        }
    }
    
    func testNextTurn() throws {
        var world = World(playerCount: 2, width: 20, height: 20, hexMapFactory: getTestMap(width:height:))
        var player1 = world.players[world.playerTurnSequence[1]]!
        player1.aiName = ""
        world.replace(player1)
        XCTAssertGreaterThan(world.allUnits.count, 0)
        
        for unit in world.allUnits {
            var changedUnit = unit
            changedUnit.actionsRemaining = 0
            world.removeUnit(changedUnit)
        }
        
        var unit = Hex_Engine.Unit(owningPlayer: world.playerTurnSequence[1], name: "countingUnit")
        unit.components = [CountingComponent(ownerID: unit.id)]
        world.addUnit(unit)
        XCTAssertEqual(unit.getComponent(CountingComponent.self)?.count, 0)
        
        let currentPlayer = world.currentPlayer
        world = world.nextTurn()
        XCTAssertNotEqual(currentPlayer, world.currentPlayer)
        
        XCTAssertGreaterThan(try world.getUnitWithID(unit.id).getComponent(CountingComponent.self)!.count, 0)
        
        for unit in world.allUnits {
            XCTAssertGreaterThan(unit.actionsRemaining, 0)
        }
        
        for _ in 0 ..< world.players.keys.count * 10 {
           world = world.nextTurn()
        }
    }
    
    func testNextPlayer() throws {
        var world = World(playerCount: 2, width: 20, height: 20, hexMapFactory: getTestMap(width:height:))
        
        let currentPlayer = world.currentPlayer!
        world = world.nextPlayer()
        XCTAssertNotEqual(currentPlayer, world.currentPlayer!)
        

    }
    
    func testExecuteCommand() throws {
        var world = World.init(playerCount: 2, width: 20, height: 20, hexMapFactory: getTestMap(width:height:))
        var unit = Hex_Engine.Unit(owningPlayer: world.playerTurnSequence[1], name: "countingUnit")
        unit.components = [CountingComponent(ownerID: unit.id)]
        world.addUnit(unit)
        XCTAssertEqual(unit.getComponent(CountingComponent.self)?.count, 0)
        
        world = world.nextTurn()
        
        XCTAssertGreaterThan(try world.getUnitWithID(unit.id).getComponent(CountingComponent.self)!.count, 0)
    }
    
    func testEncodeWorld() throws {
        let world = World.init(playerCount: 2, width: 20, height: 20, hexMapFactory: getTestMap(width:height:))
        
        let encoder = JSONEncoder()
        let encodedWorld = try encoder.encode(world)
        
        let decoder = JSONDecoder()
        let decodedWorld = try decoder.decode(World.self, from: encodedWorld)
        
        for player in world.players {
            XCTAssertTrue(decodedWorld.players.keys.contains(player.key))
        }
        
        for city in world.cities {
            XCTAssertTrue(decodedWorld.cities.keys.contains(city.key))
        }
        
        for unit in world.units {
            XCTAssertTrue(decodedWorld.units.keys.contains(unit.key))
        }
                
        for _ in 0 ..< 100 {
            let coord = world.hexMap.getTileCoordinates().randomElement()!
            XCTAssertEqual(decodedWorld.hexMap[coord], world.hexMap[coord])
        }
        
        
        
    }
    
    
}
