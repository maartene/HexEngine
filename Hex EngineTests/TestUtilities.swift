//
//  TestUtilities.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 23/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
@testable import Hex_Engine

func getTestMap(width: Int, height: Int) -> HexMap {
    var testMap = HexMap(width: width, height: height)
    for coord in testMap.getTileCoordinates() {
        testMap[coord] = Int.random(in: 0...100) <= 50 ? .Forest : .Grass
    }
    
    /*var map = ""
    for r in 0 ..< height {
        for q in 0 ..< width {
            map += "\(testMap[q,r])"
        }
        map += "\n"
    }
    print(map)*/
    
    return testMap
}

struct CountingComponent: Component {
    
    let ownerID: UUID
    let possibleCommands = [Command]()

    var count = 0
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
    }
    
    func step(in world: World) {
        guard var owner = try? world.getUnitWithID(ownerID) else {
            return
        }
            
        var updatedComponent = self
        updatedComponent.count += 1
        
        owner.replaceComponent(component: updatedComponent)
        world.replace(owner)
    }
    
    // just to implement protocol
    func encode(to encoder: Encoder) throws {
        fatalError("CountingComponent - 'func encode(to encoder: Encoder) throws' notImplemented")
    }
    
    init(from decoder: Decoder) throws {
        fatalError("CountingComponent - 'init(from decoder: Decoder) throws not' Implemented")
    }
}
