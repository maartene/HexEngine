//
//  HexMapTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 10/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class HexMapTests: XCTestCase {
    
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
    
    func testConvertCoordinateSystems() {
        let hexTile = AxialCoord(q: 3, r: 4)
        print(hexTile)
        
        let cubeTile = hexTile.toCube()
        print (cubeTile)
        
        let cubeToHexTile = cubeTile.toAxial()
        print (cubeToHexTile)
        
        assert(hexTile == cubeToHexTile)
    }
    
    func testNeighbours() {
        
        let tile = AxialCoord(q: 3, r: 4).toCube()
        print(tile)
        
        var neighbours = [AxialCoord]()
        
        for dir in 0 ..< 6 {
            let neighbour = HexMap.cubeNeighbourCoord(tile: tile, directionIndex: dir).toAxial()
            print("Neighbour \(dir): \(neighbour)")
            neighbours.append(neighbour)
        }
        
        assert(neighbours.contains(AxialCoord(q: 2, r: 5)))
        assert(neighbours.contains(AxialCoord(q: 2, r: 4)))
        assert(neighbours.contains(AxialCoord(q: 4, r: 3)))
    }
    
    func testDiagonal() {
        let tile = CubeCoord(x: 2, y: -1, z: -1)
        let diagonal = CubeCoord(x: 1, y: -2, z: 1)     // manual test case
        let diagonal2 = CubeCoord(x: 3, y: -3, z: 0)     // manual test case
        
        var diagonals = [CubeCoord]()
        for dir in 0 ..< 6 {
            let diagonalNb = HexMap.cubeDiagonalNeighbour(tile: tile, directionIndex: dir)
            print("Neighbour \(dir): \(diagonalNb)")
            diagonals.append(diagonalNb)
        }
        
        assert(diagonals.contains(diagonal))
        assert(diagonals.contains(diagonal2))
    }
    
    func testTileDidChangeHandler() {
        let tile = AxialCoord(q: 0, r: 0)
        
        let hexMap = HexMap(width: 10, height: 10)
        
        hexMap[tile] = .Grass
        assert(hexMap[tile] == .Grass)
        
        hexMap.tileDidChangedEventHandlers.append(tileDidChangeHandler)
        
        hexMap[tile] = .Forest
        assert(hexMap[tile] == .Forest)
    }
    
    func tileDidChangeHandler(tile: AxialCoord, oldValue: Tile?, newValue: Tile) {
        print("Tile \(tile) changed value from \(oldValue ?? Tile.void) to \(newValue)")
    }
    
    func testPathfinding() {
        
        let hexMap = WorldFactory.CreateWorld(width: 30, height: 20)
        
        // find two passable tiles
        var tile1: AxialCoord?
        var i = 0
        let tileCoords = hexMap.getTileCoordinates()
        while tile1 == nil && i < tileCoords.count {
            if hexMap[tileCoords[i]].blocksMovement == false {
                tile1 = tileCoords[i]
            }
            i += 1
        }
        
        var tile2: AxialCoord?
        i = tileCoords.count - 1
        while tile2 == nil && i >= 0 {
            if hexMap[tileCoords[i]].blocksMovement == false {
                tile2 = tileCoords[i]
            }
            i -= 1
        }
        
        if let tile1 = tile1, let tile2 = tile2 {
            assert(tile1 != tile2)
            
            hexMap.rebuildPathFindingGraph()
            
            if let path = hexMap.findPathFrom(tile1, to: tile2) {
                path.forEach {
                    print ("Coord: \($0) Terrain: \(hexMap[$0])")
                }                
                assert(path.count > 0)
            } else {
                print("path returned is nil - no valid path found")
                assert(false)
            }
        } else {
            print("tile1 and/or tile2 is nil: tile1: \(String(describing: tile1)) tile2: \(String(describing: tile2))")
            assert(false)
        }
        
        
        
        
    }
    

    func testHexMapRebuildPathfindingGraphPerformance() {
        // This is an example of a performance test case.
        let hexMap = WorldFactory.CreateWorld(width: 200, height: 100)
        var pass = 1
        self.measure {
            // Put the code you want to measure the time of here.
            hexMap.rebuildPathFindingGraph()
            print("testHexMapRebuildPathfindingGraphPerformance pass: \(pass) complete.")
            pass += 1
        }
    }

}