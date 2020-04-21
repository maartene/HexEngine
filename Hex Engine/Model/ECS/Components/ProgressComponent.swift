//
//  ProgressComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 16/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct ProgressComponent: Component {
    var ownerID: UUID
    var possibleCommands: [Command]
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        self.possibleCommands = []
    }
    
    func step(in world: World) -> World {
        do {
            let owner = try world.getCityWithID(ownerID)
            print(owner.yield)
            var player = try world.getPlayerWithID(owner.owningPlayerID)
            var changedWorld = world
            
            // add tech
            if var tech = player.currentlyResearchingTechnology {
                tech.costRemaining -= owner.yield.science + 5
                
                if tech.costRemaining <= 0 {
                    print("Tech done: \(tech)")
                    player.currentlyResearchingTechnology = nil
                    player.technologies.append(tech)
                } else {
                    player.currentlyResearchingTechnology = tech
                    print("Tech is now: \(tech)")
                }
            }
            
            // add gold
            player.gold += owner.yield.gold
            
            changedWorld.replace(player)
            return changedWorld
        } catch {
            print("Error while processing step for ProgressComponent: \(error)")
            return world
        }
    }
}

// MARK: Commands
struct StartResearchingTechnology: Command {
    var ownerID: UUID
    let title: String
    let technologyToResearch: Technology
    
    init(ownerID: UUID, technologyToResearch: Technology) {
        self.ownerID = ownerID
        self.technologyToResearch = technologyToResearch
        title = "Start researching \(technologyToResearch.title)"
    }
    
    func execute(in world: World) throws -> World {
        guard canExecute(in: world) else {
            return world
        }
        
        var owner = try world.getPlayerWithID(ownerID)
        owner.currentlyResearchingTechnology = technologyToResearch
        
        var changedWorld = world
        changedWorld.replace(owner)
        return changedWorld
    }
    
    func canExecute(in world: World) -> Bool {
        do {
            let owner = try world.getPlayerWithID(ownerID)
            return owner.technologies.contains(where: { tech in tech.title == technologyToResearch.title}) == false
                    
            // return true
        } catch {
            print(error)
            return false
        }
    }
}

