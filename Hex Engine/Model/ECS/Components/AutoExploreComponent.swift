//
//  AutoExploreComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 22/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct AutoExploreComponent: Component {
    let ownerID: UUID
    
    var active: Bool
    var possibleCommands: [Command]
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        self.active = false
        self.possibleCommands = [EnableAutoExploreCommand(ownerID: ownerID)]
    }
    
    func step(in world: World) {
        guard active else {
            return
        }
        
        if let owner = try? world.getUnitWithID(ownerID) {
            if let ownerMC = owner.getComponent(MovementComponent.self) {
                guard let player = world.players[owner.owningPlayerID] else {
                    return
                }
                 
                if ownerMC.path.count > 0 {
                    return
                }
                
                var range = 3
                var found = false
                while found == false && range < 10  {
                    // determine a new path
                    let coordsWithinRange = world.hexMap.reachableFromTile(owner.position.toCube(), movement: range, movementCosts: ownerMC.movementCosts)
                    let unvisitedTiles = coordsWithinRange.filter { coord in
                        player.visibilityMap[coord.toAxial(), default: .unvisited] == .unvisited
                    }
                    if unvisitedTiles.count > 0 {
                        world.executeCommand(MoveUnitCommand(ownerID: ownerID, targetTile: unvisitedTiles.randomElement()!.toAxial()))
                        found = true
                    }
                    range += 1
                }
                
                if found == false {
                    // assume there is no more left to explore
                    world.executeCommand(DisableAutoExploreCommand(ownerID: ownerID))
                }
            }
        }
    }
}

// MARK: Commands
struct EnableAutoExploreCommand: Command {
    let title = "Auto Explore"
    let ownerID: UUID
    
    func execute(in world: World) throws {
        var owner = try world.getUnitWithID(ownerID)
        
        guard var ownerAEC = owner.getComponent(AutoExploreComponent.self) else {
            return
        }
        
        ownerAEC.active = true
        ownerAEC.possibleCommands = [DisableAutoExploreCommand(ownerID: ownerID)]
        owner.replaceComponent(component: ownerAEC)
        world.replace(owner)
        let updatedAEC = try world.getUnitWithID(ownerID).getComponent(AutoExploreComponent.self)
        updatedAEC?.step(in: world)
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
    let ownerID: UUID
    
    func execute(in world: World) throws {
        var owner = try world.getUnitWithID(ownerID)
        
        guard var ownerMC = owner.getComponent(AutoExploreComponent.self) else {
            return
        }
        
        ownerMC.active = false
        ownerMC.possibleCommands = [EnableAutoExploreCommand(ownerID: ownerID)]
        owner.replaceComponent(component: ownerMC)
        world.replace(owner)
    }
    
    func canExecute(in world: World) -> Bool {
        guard let owner = try? world.getUnitWithID(ownerID) else {
            return false
        }
        
        return owner.getComponent(MovementComponent.self) != nil && owner.getComponent(AutoExploreComponent.self) != nil
    }
}
