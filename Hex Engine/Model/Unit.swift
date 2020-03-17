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
    let owningPlayer: UUID
    let name: String
    var components = [Component]()
    
    //var movement: Int
    //var movementLeft: Double
    var attackPower: Double
    var defencePower: Double
    var maxHitPoints: Double
    var currentHitPoints: Double
    var visibility: Int
    
    // var position: AxialCoord
    // var path = [AxialCoord]()
    var possibleCommands = [Command]()
    // var movementCosts: [Tile: Double]
    static var onUnitCreate: ((Unit) -> Void)?
    static var onUnitChanged: ((Unit) -> Void)?
    static var onUnitDies: ((Unit) -> Void)?
    
    init(owningPlayer: UUID, name: String, movement: Int = 2, attackPower: Double = 0.0, defencePower: Double = 1.0, maxHitPoints: Double = 5.0,
         visibility: Int = 2, startPosition: AxialCoord = AxialCoord.zero, movementCosts: [Tile: Double] = Tile.defaultCostsToEnter) {
        self.owningPlayer = owningPlayer
        self.name = name
        self.movement = movement
        self.movementLeft = Double(movement)
        self.attackPower = attackPower
        self.defencePower = defencePower
        self.maxHitPoints = maxHitPoints
        self.currentHitPoints = maxHitPoints
        self.visibility = visibility
        self.position = startPosition
        self.movementCosts = movementCosts
        Self.onUnitCreate?(self)
    }
    
    mutating func move(to position: AxialCoord) {
        self.position = position
        Self.onUnitChanged?(self)
    }
    
    func step(hexMap: HexMap) -> Unit {
        print("step for unit \(self)")
        
        var unit = self
        unit.movementLeft = Double(unit.movement)
        
        unit.move(hexMap: hexMap)
        
        return unit
    }
    
    mutating func move(hexMap: HexMap) {
        while movementLeft > 0 && path.count > 0 {
            if path.first! == position {
                path.remove(at: 0)
            }
            if path.count > 0 {
                let nextStep = path.removeFirst()
                let tile = hexMap[nextStep]
                if movementCosts[tile, default: -1] < 0 {
                    movementLeft = 0
                } else {
                    movementLeft -= movementCosts[tile, default: 0]
                }
                move(to: nextStep)
            }
        }
    }
    
    mutating func takeDamage(_ amount: Double) {
        let damageTaken = max(0, amount / defencePower)
        currentHitPoints -= damageTaken
        print("\(name): Took \(damageTaken) damage. Attacked for \(amount), defense value: \(defencePower). HP left: \(currentHitPoints)")
        Self.onUnitChanged?(self)
        
        if currentHitPoints <= 0 {
            Self.onUnitDies?(self)
        }
        
    }
    
    static func Rabbit(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newRabbit = Unit(owningPlayer: owningPlayer, name: "Rabbit", movement: 2, startPosition: startPosition)
        newRabbit.possibleCommands = [BuildCityCommand(ownerID: newRabbit.id), MoveUnitCommand(ownerID: newRabbit.id, targetTile: nil)]
        return newRabbit
    }
    
    static func Snake(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newSnake = Unit(owningPlayer: owningPlayer, name: "Snake", attackPower: 2, startPosition: startPosition)
        newSnake.possibleCommands = [MoveUnitCommand(ownerID: newSnake.id, targetTile: nil), AttackCommand(ownerID: newSnake.id, targetTile: nil)]
        return newSnake
    }
    
    static func Narwhal(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newNarwhal = Unit(owningPlayer: owningPlayer, name: "Narwhal", movement: 4, attackPower: 4, defencePower: 2, maxHitPoints: 10, visibility: 3, startPosition: startPosition)
        newNarwhal.possibleCommands = [MoveUnitCommand(ownerID: newNarwhal.id, targetTile: nil), AttackCommand(ownerID: newNarwhal.id, targetTile: nil)]
        newNarwhal.movementCosts = [.Water: 1]
        return newNarwhal
    }
}
