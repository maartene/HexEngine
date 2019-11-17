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
    
    func testCalculateVisibilityPerformanceTest() {
        // Rebuilding the pathfinding graph is notoriously expensive
        // This tests how long it takes to rebuild the pathfinding graph for a Civ VI HUGE map (106x66 tiles)
        //let world = World(playerCount: 1, width: 106, height: 66, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        let world = World(playerCount: 1, width: 212, height: 132, hexMapFactory: WorldFactory.CreateWorld(width:height:))
        
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

}
