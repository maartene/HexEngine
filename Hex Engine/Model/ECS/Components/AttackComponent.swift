//
//  AttackComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 19/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct AttackComponent: Component {
    var ownerID: UUID
    var possibleCommands: [Command]
    
    var attackPower: Double
    
    init(ownerID: UUID, attackPower: Double = 2) {
        self.ownerID = ownerID
        self.attackPower = attackPower
        
        possibleCommands = [AttackCommand(ownerID: ownerID, targetTile: nil)]
    }
    
    func step(in world: World) {
        print("AttackComponent:Step")
        // return
    }
    
    
    
}

// MARK: Commands
enum AttackCommandErrors: Error {
    case unitCannotAttack
    case notEnoughActionsLeftToAttack
}

struct AttackCommand: TileTargettingCommand, Codable {
    let title: String = "Attack"
    var ownerID: UUID
    var targetTile: AxialCoord?
    
    func execute(in world: World) throws {
        let owner = try world.getUnitWithID(ownerID)
        guard let attackComponent = owner.getComponent(AttackComponent.self) else {
            throw EntityErrors.componentNotFound(componentName: "AttackComponent")
        }
        
        guard owner.actionsRemaining > 0 else {
            throw AttackCommandErrors.notEnoughActionsLeftToAttack
        }
        
        guard let targetPosition = targetTile else {
            throw CommandErrors.missingTarget
        }
        
        // let's see whether there is a unit on the target coord
        let units = world.getUnitsOnTile(targetPosition)
        if var attackedUnit = units.first {
            guard attackedUnit.owningPlayerID != owner.owningPlayerID else {
                print("You're on the same team!")
                return
            }
            // we're attacking a unit
            print("attacking unit \(attackedUnit.name)")
            
            guard var attackedUnitHealthComponent = attackedUnit.getComponent(HealthComponent.self) else {
                return
            }
            
            attackedUnitHealthComponent.takeDamage(amount: attackComponent.attackPower)
            attackedUnit.replaceComponent(component: attackedUnitHealthComponent)
            var changedOwner = owner
            changedOwner.actionsRemaining = 0
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
        
        guard owner.getComponent(AttackComponent.self) != nil else {
            return false
        }
        
        return owner.actionsRemaining > 0
        
        
    }
}

