//
//  Unit.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

struct Unit: Entity {
    let id = UUID()
    let owningPlayerID: UUID
    var position: AxialCoord
    
    let name: String
    var components = [Component]()
    
    //var attackPower: Double
    //var defencePower: Double
    //var maxHitPoints: Double
    //var currentHitPoints: Double
    
    var visibility: Int
    
    //var possibleCommands = [Command]()

    static var onUnitCreate: ((Unit) -> Void)?
    static var onUnitChanged: ((Unit) -> Void)?
    static var onUnitDies: ((Unit) -> Void)?
    
    init(owningPlayer: UUID, name: String, visibility: Int = 2, startPosition: AxialCoord = AxialCoord.zero) {
        self.owningPlayerID = owningPlayer
        self.name = name
        self.visibility = visibility
        self.position = startPosition
        Self.onUnitCreate?(self)
    }
    
    func step(in world: World) {
        print("step for unit \(self)")
        
        for component in components {
            component.step(in: world)
        }
    }
    
    /*mutating func takeDamage(_ amount: Double) {
        let damageTaken = max(0, amount / defencePower)
        currentHitPoints -= damageTaken
        print("\(name): Took \(damageTaken) damage. Attacked for \(amount), defense value: \(defencePower). HP left: \(currentHitPoints)")
        Self.onUnitChanged?(self)
        
        if currentHitPoints <= 0 {
            Self.onUnitDies?(self)
        }
        
    }*/
    
    static func Rabbit(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newRabbit = Unit(owningPlayer: owningPlayer, name: "Rabbit", startPosition: startPosition)
        newRabbit.components = [MovementComponent(ownerID: newRabbit.id)]
        //newRabbit.possibleCommands = [BuildCityCommand(ownerID: newRabbit.id), MoveUnitCommand(ownerID: newRabbit.id, targetTile: nil)]
        return newRabbit
    }
    
    /*static func Snake(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newSnake = Unit(owningPlayer: owningPlayer, name: "Snake", attackPower: 2, startPosition: startPosition)
        newSnake.possibleCommands = [MoveUnitCommand(ownerID: newSnake.id, targetTile: nil), AttackCommand(ownerID: newSnake.id, targetTile: nil)]
        return newSnake
    }*/
    
    /*static func Narwhal(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newNarwhal = Unit(owningPlayer: owningPlayer, name: "Narwhal", movement: 4, attackPower: 4, defencePower: 2, maxHitPoints: 10, visibility: 3, startPosition: startPosition)
        newNarwhal.possibleCommands = [MoveUnitCommand(ownerID: newNarwhal.id, targetTile: nil), AttackCommand(ownerID: newNarwhal.id, targetTile: nil)]
        newNarwhal.movementCosts = [.Water: 1]
        return newNarwhal
    }*/
}
