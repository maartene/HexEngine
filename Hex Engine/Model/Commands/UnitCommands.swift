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

enum AttackCommandErrors: Error {
    case unitCannotAttack
    case notEnoughMovementLeftToAttack
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

struct MoveUnitCommand: TileTargettingCommand, Codable {
    let title: String = "Move"
    
    var ownerID: UUID
    
    var targetTile: AxialCoord?
    
    func execute(in world: World) throws {
        let owner = try world.getUnitWithID(ownerID)
        
        world.hexMap.rebuildPathFindingGraph(movementCosts: owner.movementCosts)
        
        guard let targetPosition = targetTile else {
            throw CommandErrors.missingTarget
        }
        
        guard let path = world.hexMap.findPathFrom(owner.position, to: targetPosition, movementCosts: owner.movementCosts) else {
            print("No valid path from \(owner.position) to \(targetPosition).")
            return
        }
        
        print("Calculate path: \(path)")
        world.setPath(for: ownerID, path: path, moveImmediately: true)
    }
    
    func canExecute(in world: World) -> Bool {
        if let owner = try? world.getUnitWithID(ownerID) {
            return owner.movement > 0
        }
        
        return false
    }
}

struct AttackCommand: TileTargettingCommand, Codable {
    let title: String = "Attack"
    var ownerID: UUID
    var targetTile: AxialCoord?
    
    func execute(in world: World) throws {
        let owner = try world.getUnitWithID(ownerID)
        guard owner.movementLeft > 0 else {
            throw AttackCommandErrors.notEnoughMovementLeftToAttack
        }
        
        guard owner.attackPower > 0 else {
            throw AttackCommandErrors.unitCannotAttack
        }
        
        guard let targetPosition = targetTile else {
            throw CommandErrors.missingTarget
        }
        
        // let's see whether there is a unit on the target coord
        let units = world.getUnitsOnTile(targetPosition)
        if var attackedUnit = units.first {
            guard attackedUnit.owningPlayer != owner.owningPlayer else {
                print("You're on the same team!")
                return
            }
            // we're attacking a unit
            print("attacking unit \(attackedUnit.name)")
            attackedUnit.takeDamage(owner.attackPower)
            var changedOwner = owner
            changedOwner.movementLeft = 0
            world.replace(changedOwner)
            world.replace(attackedUnit)
            return
        }
        
        if let city = world.getCityAt(targetPosition) {
            // we're attacking a city
            print("attacking city \(city.name)")
            return
        }
        
        throw CommandErrors.illegalTarget
    }
    
    func canExecute(in world: World) -> Bool {
        guard let owner = try? world.getUnitWithID(ownerID) else {
            return false
        }
        
        return owner.attackPower > 0
    }
}
