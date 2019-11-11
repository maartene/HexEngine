//
//  CityCommands.swift
//  Hex Engine
//
//  Created by Maarten Engels on 20/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

enum CityCommandErrors: Error {
    case builderIsNotACityError
}

// Don't call this command directly, but execute it from a Queue command instead.
struct BuildRabbitCommand: BuildCommand, Codable {    
    var productionRemaining = 10.0
    
    var title = "Breed Rabbit"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getCityWithID(ownerID)
        let newUnit = Unit.Rabbit(startPosition: owner.position)
        
        world.addUnit(newUnit)
        return
    }
}

struct QueueBuildRabbitCommand: Command, Codable {
    var title = "Breed Rabbit"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getCityWithID(ownerID)
        guard let changedOwner = owner.addToBuildQueue(BuildRabbitCommand(ownerID: ownerID)) as? City else {
            throw CityCommandErrors.builderIsNotACityError
        }
        
        world.replace(changedOwner)
        return
    }
}
