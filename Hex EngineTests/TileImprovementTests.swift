//
//  TileImprovementTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 09/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class TileImprovementTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTileImprovementChangesTileYield() throws {
        var world = World(playerCount: 1, width: 10, height: 10, hexMapFactory: getTestMap(width:height:))
        world.hexMap[AxialCoord.zero] = .Forest
        let originalYield = world.getTileYield(for: AxialCoord.zero)
        
        let camp = TileImprovement.getProtype(title: "Camp", at: AxialCoord.zero)
        world = try world.addImprovement(camp)
        
        let newYield = world.getTileYield(for: AxialCoord.zero)
        
        XCTAssertNotEqual(originalYield, newYield)
    }

}
