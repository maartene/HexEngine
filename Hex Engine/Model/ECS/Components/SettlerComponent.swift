//
//  SettlerComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

enum FoundCityCommandErrors: Error {
    case tileAlreadyOccupied
    case tileOfWrongType
}

struct SettlerComponent: Component {
    var ownerID: UUID
    
    var possibleCommands: [Command]
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        
        possibleCommands = [FoundCityCommand(ownerID: ownerID)]
    }
    
    func step(in world: World) {
        return
    }
}


// MARK: Commands
struct FoundCityCommand: Command, Codable {
    let title = "Found city"
    
    let ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getUnitWithID(ownerID)
        
        guard world.getCityAt(owner.position) == nil else {
            throw FoundCityCommandErrors.tileAlreadyOccupied
        }
        
        let tile = world.hexMap[owner.position.q, owner.position.r]
        guard tile == .Grass || tile == .Sand else {
            throw FoundCityCommandErrors.tileOfWrongType
        }
        
        let city = City(owningPlayer: owner.owningPlayerID, name: "New city \(Int.random(in: 0...100))", position: owner.position)
        world.addCity(city)
        
        // remove unit from world
        world.removeUnit(owner)
        
        return
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
