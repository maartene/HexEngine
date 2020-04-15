//
//  AutoExploreComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 22/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct AutoExploreComponent: Component {
    var ownerID: UUID
    
    var active: Bool
    var possibleCommands: [Command]
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        self.active = false
        self.possibleCommands = [EnableAutoExploreCommand(ownerID: ownerID)]
    }
    
    func step(in world: World) -> World {
        guard active else {
            return world
        }
        
        var updatedWorld = world
        
        if let owner = try? updatedWorld.getUnitWithID(ownerID) {
            if let ownerMC = owner.getComponent(MovementComponent.self) {
                guard let player = updatedWorld.players[owner.owningPlayerID] else {
                    return updatedWorld
                }
                 
                if ownerMC.path.count > 0 {
                    return updatedWorld
                }
                
                var range = 3
                var found = false
                while found == false && range < 10  {
                    // determine a new path
                    let coordsWithinRange = updatedWorld.hexMap.reachableFromTile(owner.position.toCube(), movement: range, movementCosts: ownerMC.movementCosts)
                    let unvisitedTiles = coordsWithinRange.filter { coord in
                        player.visibilityMap[coord.toAxial(), default: .unvisited] == .unvisited
                    }
                    if unvisitedTiles.count > 0 {
                        updatedWorld = updatedWorld.executeCommand(MoveUnitCommand(ownerID: ownerID, targetTile: unvisitedTiles.randomElement()!.toAxial()))
                        found = true
                    }
                    range += 1
                }
                
                if found == false {
                    // assume there is no more left to explore
                    updatedWorld = world.executeCommand(DisableAutoExploreCommand(ownerID: ownerID))
                }
            }
        }
        return updatedWorld
    }
}

// MARK: Commands
struct EnableAutoExploreCommand: Command {
    let title = "Auto Explore"
    var ownerID: UUID
    
    func execute(in world: World) throws -> World {
        var owner = try world.getUnitWithID(ownerID)
        
        guard var ownerAEC = owner.getComponent(AutoExploreComponent.self) else {
            return world
        }
        
        var updatedWorld = world
        ownerAEC.active = true
        ownerAEC.possibleCommands = [DisableAutoExploreCommand(ownerID: ownerID)]
        owner.replaceComponent(component: ownerAEC)
        updatedWorld.replace(owner)
        let updatedAEC = try updatedWorld.getUnitWithID(ownerID).getComponent(AutoExploreComponent.self)
        return updatedAEC?.step(in: updatedWorld) ?? updatedWorld
    }
    
    func canExecute(in world: World) -> Bool {
        guard let owner = try? world.getUnitWithID(ownerID) else {
            return false
        }
        
        return owner.getComponent(MovementComponent.self) != nil && owner.getComponent(AutoExploreComponent.self) != nil
    }
}

struct DisableAutoExploreCommand: Command {
    let title = "Stop Auto Exploring"
    var ownerID: UUID
    
    func execute(in world: World) throws -> World {
        var owner = try world.getUnitWithID(ownerID)
        
        guard var ownerMC = owner.getComponent(AutoExploreComponent.self) else {
            return world
        }
        
        var updatedWorld = world
        
        ownerMC.active = false
        ownerMC.possibleCommands = [EnableAutoExploreCommand(ownerID: ownerID)]
        owner.replaceComponent(component: ownerMC)
        updatedWorld.replace(owner)
        return updatedWorld
    }
    
    func canExecute(in world: World) -> Bool {
        guard let owner = try? world.getUnitWithID(ownerID) else {
            return false
        }
        
        return owner.getComponent(MovementComponent.self) != nil && owner.getComponent(AutoExploreComponent.self) != nil
    }
}
