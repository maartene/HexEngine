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
    let id: UUID
    let owningPlayerID: UUID
    var position: AxialCoord
    
    let name: String
    var components = [Component]()
    
    var visibility: Int
    var actionsRemaining = 2.0

    init(owningPlayer: UUID, name: String, visibility: Int = 2, startPosition: AxialCoord = AxialCoord.zero) {
        self.id = UUID()
        self.owningPlayerID = owningPlayer
        self.name = name
        self.visibility = visibility
        self.position = startPosition
    }
    
    static func Rabbit(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newRabbit = Unit(owningPlayer: owningPlayer, name: "Rabbit", startPosition: startPosition)
        newRabbit.components = [MovementComponent(ownerID: newRabbit.id), SettlerComponent(ownerID: newRabbit.id), HealthComponent(ownerID: newRabbit.id), AutoExploreComponent(ownerID: newRabbit.id)]
        return newRabbit
    }
    
    static func Snake(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newSnake = Unit(owningPlayer: owningPlayer, name: "Snake", startPosition: startPosition)
        newSnake.components = [MovementComponent(ownerID: newSnake.id), HealthComponent(ownerID: newSnake.id), AttackComponent(ownerID: newSnake.id, attackPower: 8), AutoExploreComponent(ownerID: newSnake.id)]
        return newSnake
    }
    
    static func Narwhal(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newNarwhal = Unit(owningPlayer: owningPlayer, name: "Narwhal", startPosition: startPosition)
        newNarwhal.components = [MovementComponent(ownerID: newNarwhal.id, movementCosts: [.Water: 0.5]), HealthComponent(ownerID: newNarwhal.id), AutoExploreComponent(ownerID: newNarwhal.id)]
        return newNarwhal
    }
    
    static func Reindeer(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newReindeer = Unit(owningPlayer: owningPlayer, name: "Reindeer", startPosition: startPosition)
        var movementCosts = Tile.defaultCostsToEnter
        movementCosts[.Forest] = 0.5
        movementCosts[.Grass] = 0.75
        movementCosts[.Sand] = 0.75
        newReindeer.components = [MovementComponent(ownerID: newReindeer.id, movementCosts: movementCosts), HealthComponent(ownerID: newReindeer.id, maxHitPoints: 15), AutoExploreComponent(ownerID: newReindeer.id)]
        return newReindeer
    }
    
    static func nullUnit(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        print("WARNING: creating nullUnit. Probably not intentional.")
        assert(false)
        return Unit(owningPlayer: owningPlayer, name: "Null Unit", startPosition: startPosition)
    }
    
    static let allUnits = ["Narwhal": Unit.Narwhal, "Rabbit": Unit.Rabbit, "Snake": Unit.Snake, "Reindeer": Unit.Reindeer]
    static let unitProductionRequirements: [String: Double] = ["Narwhal": 15, "Rabbit": 10, "Snake": 5, "Reindeer": 20]
}
