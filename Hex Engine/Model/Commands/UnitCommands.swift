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

struct BuildCityCommand: Command, Codable {
    let title = "Dig rabbit hole"
    
    let ownerID: UUID
    
    func execute(in world: World) throws {
        let owner = try world.getUnitWithID(ownerID)
        
        guard world.getCityAt(owner.position) == nil else {
            throw BuildCityCommandErrors.tileAlreadyOccupied
        }
        
        let tile = world.hexMap[owner.position.q, owner.position.r]
        guard tile == .Grass || tile == .Sand else {
            throw BuildCityCommandErrors.tileOfWrongType
        }
        
        let city = City(owningPlayer: owner.owningPlayer, name: "New city \(Int.random(in: 0...100))", position: owner.position)
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

struct MoveUnitCommand: Command, Codable {
    let title: String = "Move"
    
    var ownerID: UUID
    
    var targetPosition: AxialCoord
    
    func execute(in world: World) throws {
        let owner = try world.getUnitWithID(ownerID)
        
        world.hexMap.rebuildPathFindingGraph()
        
        guard let path = world.hexMap.findPathFrom(owner.position, to: targetPosition) else {
            print("No valid path from \(owner.position) to \(targetPosition).")
            return
        }
        
        print("Calculate path: \(path)")
        world.setPath(for: ownerID, path: path, moveImmediately: true)
    }
}
