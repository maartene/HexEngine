//
//  BuildImprovementComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 08/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct BuildImprovementComponent: Component {
    var ownerID: UUID

    let possibleCommands: [Command]
    let maxEnergy: Double
    var currentEnergy: Double
    
    init(ownerID: UUID, maxEnergy: Double = 5.0) {
        self.ownerID = ownerID
        self.maxEnergy = maxEnergy
        currentEnergy = maxEnergy
        
        possibleCommands = TileImprovement.Prototypes.map { BuildTileImprovementCommand(ownerID: ownerID, componentToBuildName: $0.title) }
    }
    
    func step(in world: World) -> World {
        // regain some energy
        do {
            var owner = try world.getUnitWithID(ownerID)
            guard var bic = owner.getComponent(BuildImprovementComponent.self) else {
                throw EntityErrors.componentNotFound(componentName: "BuildImprovementComponent")
            }
            
            bic.currentEnergy = min(currentEnergy + 0.2, maxEnergy)
            owner.replaceComponent(component: bic)
            var changedWorld = world
            changedWorld.replace(owner)
            return changedWorld
        } catch {
            print(error)
            return world
        }
    }
}

// MARK: COMMANDS
struct BuildTileImprovementCommand: Command {
    var ownerID: UUID
    let title: String
    let componentToBuildName: String
    
    init(ownerID: UUID, componentToBuildName: String) {
        self.ownerID = ownerID
        self.componentToBuildName = componentToBuildName
        self.title = "Build \(componentToBuildName)"
    }
    
    func execute(in world: World) throws -> World {
        guard canExecute(in: world) else {
            return world
        }
        
        var owner = try world.getUnitWithID(ownerID)
        
        let newImprovement = TileImprovement.getProtype(title: componentToBuildName, at: owner.position)

        var bic = try owner.tryGetComponent(BuildImprovementComponent.self)
        
        owner.actionsRemaining = 0
        bic.currentEnergy -= newImprovement.energyRequired
        
        owner.replaceComponent(component: bic)
        var changedWorld = world
        changedWorld.replace(owner)
        
        return try changedWorld.addImprovement(newImprovement)
    }
    
    func canExecute(in world: World) -> Bool {
        do {
            let owner = try world.getUnitWithID(ownerID)
            
            guard world.getCityAt(owner.position) == nil else {
                return false
            }
            
            let bic = try owner.tryGetComponent(BuildImprovementComponent.self)
            
            let improvement = TileImprovement.getProtype(title: componentToBuildName, at: owner.position)
            
            guard improvement.allowedTileTypes.contains(world.hexMap[owner.position]) else {
                return false
            }
            
            guard bic.currentEnergy >= improvement.energyRequired else {
                return false
            }
            
            guard world.improvements[owner.position] == nil else {
                return false
            }
            
            guard owner.actionsRemaining > 0 else {
                return false
            }
            
            return true
        } catch {
            print(error)
            return false
        }
    }
}

