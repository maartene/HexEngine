//
//  PlayerTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 17/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class PlayerTests: XCTestCase {
    
    var world: World!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        world = World(playerCount: 1, width: 20, height: 20, hexMapFactory: getTestMap(width:height:))
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
    
    func testPlayerCalculateVisibility() throws {
        if let player = world.currentPlayer?.calculateVisibility(in: world) {
            let visibleCount = player.visibilityMap.values.filter { tile in tile == .visible }.count
            
            let unit = Hex_Engine.Unit(owningPlayer: player.id, name: "TestUnit", visibility: 5, productionRequired: 5, startPosition: world.hexMap.getTileCoordinates().randomElement()!)
            world.addUnit(unit)
            
            let updatedPlayer = world.currentPlayer!.calculateVisibility(in: world)
            let updatedVisibleCount = updatedPlayer.visibilityMap.values.filter { tile in tile == .visible }.count
            
        XCTAssertGreaterThan(updatedVisibleCount, visibleCount)
            
        } else {
            XCTAssertTrue(false)
        }
    }
    
    func testEncodePlayer() throws {
        let player = Player(name: "testPlayer\(Int.random(in: 0...10000))")
        let encoder = JSONEncoder()
        let encodedPlayer = try encoder.encode(player)
        
        let decoder = JSONDecoder()
        let decodedPlayer = try decoder.decode(Player.self, from: encodedPlayer)
        
        XCTAssertEqual(decodedPlayer.id, player.id)
        XCTAssertEqual(decodedPlayer.aiName, player.aiName)
        XCTAssertEqual(decodedPlayer.name, player.name)
    }

}
