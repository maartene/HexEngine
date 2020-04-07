//
//  AttackComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 19/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

struct AttackComponent: Component {
    var ownerID: UUID
    var possibleCommands: [Command]
    var range: Int
    var attackPower: Double
    
    init(ownerID: UUID, attackPower: Double = 2, range: Int = 1) {
        self.ownerID = ownerID
        self.attackPower = attackPower
        self.range = range
        
        possibleCommands = [AttackCommand(ownerID: ownerID, targetTile: nil, range: range)]
    }
    
    func step(in world: World) -> World{
        print("AttackComponent:Step")
        return world
    }
}

// MARK: Commands
enum AttackCommandErrors: Error {
    case unitCannotAttack
    case notEnoughActionsLeftToAttack
    case targetOutOfRange
}

struct AttackCommand: TileTargettingCommand, Codable {
    let title: String = "Attack"
    let hasFilter = true
    let ownerID: UUID
    var targetTile: AxialCoord?
    let range: Int
    
    func execute(in world: World) throws -> World {
        var changedWorld = world
        let owner = try changedWorld.getUnitWithID(ownerID)
        guard let attackComponent = owner.getComponent(AttackComponent.self) else {
            throw EntityErrors.componentNotFound(componentName: "AttackComponent")
        }
        
        guard owner.actionsRemaining > 0 else {
            throw AttackCommandErrors.notEnoughActionsLeftToAttack
        }
        
        guard let targetPosition = targetTile else {
            throw CommandErrors.missingTarget
        }
        
        guard HexMap.distance(from: owner.position, to: targetPosition) <= range else {
            throw AttackCommandErrors.targetOutOfRange
        }
        
        // let's see whether there is a unit on the target coord
        let units = changedWorld.getUnitsOnTile(targetPosition)
        if var attackedUnit = units.first {
            guard attackedUnit.owningPlayerID != owner.owningPlayerID else {
                print("You're on the same team!")
                return changedWorld
            }
            // we're attacking a unit
            print("attacking unit \(attackedUnit.name)")
            
            guard var attackedUnitHealthComponent = attackedUnit.getComponent(HealthComponent.self) else {
                return changedWorld
            }
            
            attackedUnitHealthComponent.takeDamage(amount: attackComponent.attackPower)
            attackedUnit.replaceComponent(component: attackedUnitHealthComponent)
            var changedOwner = owner
            changedOwner.actionsRemaining = 0
            changedWorld.replace(changedOwner)
            changedWorld.replace(attackedUnit)
            return changedWorld
        }
        
        if let city = changedWorld.getCityAt(targetPosition) {
            // we're attacking a city
            print("attacking city \(city.name)")
            return changedWorld
        }
        
        throw CommandErrors.illegalTarget
    }
    
    func canExecute(in world: World) -> Bool {
        guard let owner = try? world.getUnitWithID(ownerID) else {
            return false
        }
        
        guard owner.getComponent(AttackComponent.self) != nil else {
            return false
        }
        
        return owner.actionsRemaining > 0
        
        
    }
    
    func getValidTargets(in world: World) throws -> [AxialCoord] {
        let owner = try world.getUnitWithID(ownerID)
        let player = try world.getPlayerWithID(owner.owningPlayerID)
        
        let validTiles =
            player.visibilityMap.filter({ element in element.value == .visible }).map { element in element.key } // only visible tiles count
                .filter({ coord in HexMap.distance(from: owner.position, to: coord) <= range }) // only tiles within range count
                .filter({ coord in
                    world.getUnitsOnTile(coord).filter( { unit in unit.owningPlayerID != player.id }).count > 0 ||
                        world.getCityAt(coord)?.owningPlayerID ?? player.id != player.id
                }) // only tiles with enemy units count
        return validTiles
    }
}

