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
        let newUnit = Unit.Rabbit(owningPlayer: owner.owningPlayer, startPosition: owner.position)
        
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

// Don't call this command directly, but execute it from a Queue command instead.
struct BuildSnakeCommand: BuildCommand, Codable {
    var productionRemaining = 15.0
    
    var title = "Breed Snake"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getCityWithID(ownerID)
        let newUnit = Unit.Snake(owningPlayer: owner.owningPlayer, startPosition: owner.position)
        
        world.addUnit(newUnit)
        return
    }
}

struct QueueBuildSnakeCommand: Command, Codable {
    var title = "Breed Snake"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getCityWithID(ownerID)
        guard let changedOwner = owner.addToBuildQueue(BuildSnakeCommand(ownerID: ownerID)) as? City else {
            throw CityCommandErrors.builderIsNotACityError
        }
        
        world.replace(changedOwner)
        return
    }
}

// Don't call this command directly, but execute it from a Queue command instead.
struct BuildNarwhalCommand: BuildCommand, Codable {
    var productionRemaining = 5.0
    
    var title = "Breed Narwhal"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getCityWithID(ownerID)
        let newUnit = Unit.Narwhal(owningPlayer: owner.owningPlayer, startPosition: owner.position)
        
        world.addUnit(newUnit)
        return
    }
}

struct QueueBuildNarwhalCommand: Command, Codable {
    var title = "Breed Narwhal"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getCityWithID(ownerID)
        guard let changedOwner = owner.addToBuildQueue(BuildNarwhalCommand(ownerID: ownerID)) as? City else {
            throw CityCommandErrors.builderIsNotACityError
        }
        
        world.replace(changedOwner)
        return
    }
}

struct RemoveFromBuildQueueCommand: Command, Codable {
    var title = "Remove from build queue"
    
    var ownerID: UUID
    
    let commandToRemoveIndex: Int
    
    func execute(in world: World) throws {
        var city = try world.getCityWithID(ownerID)
        
        city.buildQueue.remove(at: commandToRemoveIndex)
        
        world.replace(city)
        return
    }
    
}
