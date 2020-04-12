//
//  TestUtilities.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 23/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
@testable import Hex_Engine

func getTestMap(width: Int, height: Int) -> HexMap {
    var testMap = HexMap(width: width, height: height)
    for coord in testMap.getTileCoordinates() {
        testMap[coord] = Int.random(in: 0...100) <= 50 ? .Forest : .Grass
    }
    
    /*var map = ""
    for r in 0 ..< height {
        for q in 0 ..< width {
            map += "\(testMap[q,r])"
        }
        map += "\n"
    }
    print(map)*/
    
    return testMap
}

struct CountingComponent: Component {
    
    var ownerID: UUID
    var possibleCommands = [Command]()

    var count = 0
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
    }
    
    func step(in world: World) -> World {
        guard var owner = try? world.getUnitWithID(ownerID) else {
            return world
        }
            
        var updatedComponent = self
        updatedComponent.count += 1
        
        owner.replaceComponent(component: updatedComponent)
        var changedWorld = world
        changedWorld.replace(owner)
        return changedWorld
    }
    
    // just to implement protocol
    func encode(to encoder: Encoder) throws {
        fatalError("CountingComponent - 'func encode(to encoder: Encoder) throws' notImplemented")
    }
    
    init(from decoder: Decoder) throws {
        fatalError("CountingComponent - 'init(from decoder: Decoder) throws not' Implemented")
    }
}

func Rabbit(owningPlayer: UUID, startPosition: AxialCoord) -> Hex_Engine.Unit {
        var newRabbit = Unit(owningPlayer: owningPlayer, name: "Rabbit", productionRequired: 10, startPosition: startPosition)
        newRabbit.components = [MovementComponent(ownerID: newRabbit.id), SettlerComponent(ownerID: newRabbit.id), HealthComponent(ownerID: newRabbit.id), AutoExploreComponent(ownerID: newRabbit.id)]
        return newRabbit
    }

func Snake(owningPlayer: UUID, startPosition: AxialCoord) -> Hex_Engine.Unit {
    var newSnake = Unit(owningPlayer: owningPlayer, name: "Snake",productionRequired: 5, startPosition: startPosition)
    newSnake.components = [MovementComponent(ownerID: newSnake.id), HealthComponent(ownerID: newSnake.id), AttackComponent(ownerID: newSnake.id, attackPower: 8, range: 2), AutoExploreComponent(ownerID: newSnake.id)]
    return newSnake
}

func Crocodile(owningPlayer: UUID, startPosition: AxialCoord) -> Hex_Engine.Unit {
    var newCrocodile = Unit(owningPlayer: owningPlayer, name: "Crocodile", productionRequired: 10, startPosition: startPosition)
    newCrocodile.components = [MovementComponent(ownerID: newCrocodile.id), HealthComponent(ownerID: newCrocodile.id), AttackComponent(ownerID: newCrocodile.id, attackPower: 8), AutoExploreComponent(ownerID: newCrocodile.id)]
    return newCrocodile
}

func Narwhal(owningPlayer: UUID, startPosition: AxialCoord) -> Hex_Engine.Unit {
    var newNarwhal = Unit(owningPlayer: owningPlayer, name: "Narwhal", productionRequired: 15, startPosition: startPosition)
    newNarwhal.components = [MovementComponent(ownerID: newNarwhal.id, movementCosts: [.Water: 0.5]), HealthComponent(ownerID: newNarwhal.id), AutoExploreComponent(ownerID: newNarwhal.id)]
    return newNarwhal
}

func Reindeer(owningPlayer: UUID, startPosition: AxialCoord) -> Hex_Engine.Unit {
    var newReindeer = Unit(owningPlayer: owningPlayer, name: "Reindeer", visibility: 1, productionRequired: 20,  startPosition: startPosition)
    var movementCosts = Tile.defaultCostsToEnter
    movementCosts[.Forest] = 0.5
    movementCosts[.Grass] = 0.75
    movementCosts[.Sand] = 0.75
    newReindeer.components = [MovementComponent(ownerID: newReindeer.id, movementCosts: movementCosts), HealthComponent(ownerID: newReindeer.id, maxHitPoints: 15), AutoExploreComponent(ownerID: newReindeer.id)]
    return newReindeer
}

func Beaver(owningPlayer: UUID, startPosition: AxialCoord) -> Hex_Engine.Unit {
    var newBeaver = Unit(owningPlayer: owningPlayer, name: "Beaver", productionRequired: 15, startPosition: startPosition)
    newBeaver.components = [MovementComponent(ownerID: newBeaver.id), BuildImprovementComponent(ownerID: newBeaver.id)]
    return newBeaver
}
