//
//  UnitCommands.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

enum BuildCityCommandErrors: Error {
    case tileAlreadyOccupied
    case tileOfWrongType
}

struct BuildCityCommand: Command {
    let title = "Dig rabbit hole"
    
    let ownerID: UUID
    
    func execute(in world: World) throws -> World {
        let owner = try world.getUnitWithID(ownerID)
        
        guard world.getCityAt(owner.position) == nil else {
            throw BuildCityCommandErrors.tileAlreadyOccupied
        }
        
        let tile = world.hexMap[owner.position.q, owner.position.r]
        guard tile == .Grass || tile == .Sand else {
            throw BuildCityCommandErrors.tileOfWrongType
        }
        
        var changedWorld = world
        let city = City(name: "New city \(Int.random(in: 0...100))", position: owner.position)
        changedWorld.addCity(city)
        
        // remove unit from world
        changedWorld.removeUnit(owner)
        
        return changedWorld
    }
    
    func canExecute(in world: World) -> Bool {
        guard let owner = try? world.getUnitWithID(ownerID) else {
            return false
        }
        
        guard world.getCityAt(owner.position) == nil else {
            return false
        }
        
        let tile = world.hexMap[owner.position.q, owner.position.r]
        guard tile == .Grass || tile == .Sand else {
            return false
        }
        
        return true
    }
}
