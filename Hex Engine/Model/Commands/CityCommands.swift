//
//  CityCommands.swift
//  Hex Engine
//
//  Created by Maarten Engels on 20/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct BuildRabbitCommand: BuildCommand {    
    var productionRemaining = 10.0
    
    var title = "Breed Rabbit"
    
    var ownerID: UUID
    
    func execute(in world: World) throws -> World {
        let owner = try world.getCityWithID(ownerID)
        let newUnit = Unit(name: "Rabbit", movement: 2, startPosition: owner.position)
        
        var newWorld = world
        newWorld.addUnit(newUnit)
        return newWorld
    }
}
