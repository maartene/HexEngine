//
//  HealthComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct HealthComponent: Component {
    var ownerID: UUID
    var possibleCommands: [Command]
    
    var defencePower: Double
    var maxHitPoints: Double
    var currentHitPoints: Double
    
    var isDead: Bool {
        return currentHitPoints <= 0
    }
    
    init(ownerID: UUID, defencePower: Double = 1, maxHitPoints: Double = 10) {
        self.ownerID = ownerID
        self.defencePower = defencePower
        self.maxHitPoints = maxHitPoints
        currentHitPoints = maxHitPoints
        
        possibleCommands = []
    }
    
    func step(in world: World) -> World {
        guard var owner = try? world.getUnitWithID(ownerID) else {
            return world
        }
        
        // heal a bit
        var changedComponent = self
        changedComponent.currentHitPoints += 0.1 * changedComponent.maxHitPoints
        changedComponent.currentHitPoints = min(changedComponent.currentHitPoints, changedComponent.maxHitPoints)
        
        owner.replaceComponent(component: changedComponent)
        var updatedWorld = world
        updatedWorld.replace(owner)
        return updatedWorld
    }
    
    mutating func takeDamage(amount: Double) {
        let damageTaken = max(0, amount / defencePower)
        currentHitPoints -= damageTaken
        print("Took \(damageTaken) damage. Attacked for \(amount), defense value: \(defencePower). HP left: \(currentHitPoints)")
    }
}

