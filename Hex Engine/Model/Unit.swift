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
    
    static var Prototypes: [Unit] = Bundle.main.decode([Unit].self, from: "units.json")
    static func getPrototype(unitName: String) -> Unit {
        if var unit = Prototypes.first(where: { $0.name == unitName }) {
            // the prototype comes with a default ID. Make sure it gets a unique ID.
            unit.assignUniqueID()
            return unit
        } else {
            fatalError("No Unit prototype with name \(unitName) found.")
        }
    }
    static func getPrototype(unitName: String, for owningPlayerID: UUID, startPosition: AxialCoord = AxialCoord.zero) -> Unit {
        var unit = getPrototype(unitName: unitName)
        unit.position = startPosition
        unit.owningPlayerID = owningPlayerID
        return unit
    }
    
    var id: UUID
    var owningPlayerID: UUID
    var position: AxialCoord
    
    let name: String
    var components = [Component]()
    
    var visibility: Int
    var actionsRemaining = 2.0
    let productionRequired: Double

    init(owningPlayer: UUID, name: String, visibility: Int = 1, productionRequired: Double, startPosition: AxialCoord = AxialCoord.zero) {
        self.id = UUID()
        self.owningPlayerID = owningPlayer
        self.name = name
        self.visibility = visibility
        self.productionRequired = productionRequired
        self.position = startPosition
    }
    
    mutating func assignUniqueID() {
        id = UUID()
        components = components.map { component in
            var changedComponent = component
            changedComponent.ownerID = id
            changedComponent.possibleCommands = changedComponent.possibleCommands.map { command in
                var changedCommand = command
                changedCommand.ownerID = id
                return changedCommand
            }
            return changedComponent
        }
    }
    
    /*
    static func Rabbit(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newRabbit = Unit(owningPlayer: owningPlayer, name: "Rabbit", productionRequired: 10, startPosition: startPosition)
        newRabbit.components = [MovementComponent(ownerID: newRabbit.id), SettlerComponent(ownerID: newRabbit.id), HealthComponent(ownerID: newRabbit.id), AutoExploreComponent(ownerID: newRabbit.id)]
        return newRabbit
    }
    
    static func Snake(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newSnake = Unit(owningPlayer: owningPlayer, name: "Snake",productionRequired: 5, startPosition: startPosition)
        newSnake.components = [MovementComponent(ownerID: newSnake.id), HealthComponent(ownerID: newSnake.id), AttackComponent(ownerID: newSnake.id, attackPower: 8, range: 2), AutoExploreComponent(ownerID: newSnake.id)]
        return newSnake
    }
    
    static func Crocodile(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newCrocodile = Unit(owningPlayer: owningPlayer, name: "Crocodile", productionRequired: 10, startPosition: startPosition)
        newCrocodile.components = [MovementComponent(ownerID: newCrocodile.id), HealthComponent(ownerID: newCrocodile.id), AttackComponent(ownerID: newCrocodile.id, attackPower: 8), AutoExploreComponent(ownerID: newCrocodile.id)]
        return newCrocodile
    }
    
    static func Narwhal(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newNarwhal = Unit(owningPlayer: owningPlayer, name: "Narwhal", productionRequired: 15, startPosition: startPosition)
        newNarwhal.components = [MovementComponent(ownerID: newNarwhal.id, movementCosts: [.Water: 0.5]), HealthComponent(ownerID: newNarwhal.id), AutoExploreComponent(ownerID: newNarwhal.id)]
        return newNarwhal
    }
    
    static func Reindeer(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newReindeer = Unit(owningPlayer: owningPlayer, name: "Reindeer", visibility: 1, productionRequired: 20,  startPosition: startPosition)
        var movementCosts = Tile.defaultCostsToEnter
        movementCosts[.Forest] = 0.5
        movementCosts[.Grass] = 0.75
        movementCosts[.Sand] = 0.75
        newReindeer.components = [MovementComponent(ownerID: newReindeer.id, movementCosts: movementCosts), HealthComponent(ownerID: newReindeer.id, maxHitPoints: 15), AutoExploreComponent(ownerID: newReindeer.id)]
        return newReindeer
    }
    
    static func Beaver(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newBeaver = Unit(owningPlayer: owningPlayer, name: "Beaver", productionRequired: 15, startPosition: startPosition)
        newBeaver.components = [MovementComponent(ownerID: newBeaver.id), BuildImprovementComponent(ownerID: newBeaver.id)]
        return newBeaver
    }
    
    static func nullUnit(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        print("WARNING: creating nullUnit. Probably not intentional.")
        assert(false)
        return Unit(owningPlayer: owningPlayer, name: "Null Unit", productionRequired: 0, startPosition: startPosition)
    }
    
    static func getUnitByName(unitName: String, ownerID: UUID, startPosition: AxialCoord = AxialCoord.zero) -> Unit {
        if let unit = allUnits[unitName]?(ownerID, startPosition) {
            return unit
        } else {
            return nullUnit(owningPlayer: ownerID, startPosition: startPosition)
        }
    }
    
    static let allUnits = ["Narwhal": Unit.Narwhal, "Rabbit": Unit.Rabbit, "Snake": Unit.Snake, "Reindeer": Unit.Reindeer, "Crocodile": Unit.Crocodile, "Beaver": Unit.Beaver]
     */
}
