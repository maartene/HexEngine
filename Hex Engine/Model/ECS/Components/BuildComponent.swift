//
//  BuilderComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct BuildComponent: Component {
    var ownerID: UUID
    
    let possibleCommands: [Command]
    var buildQueue = [BuildCommand]()
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        
        var possibleCommands = [Command]()
        for entry in Unit.allUnits.keys {
            possibleCommands.append(QueueBuildUnitCommand(ownerID: ownerID, unitToBuildName: entry))
        }
        self.possibleCommands = possibleCommands
    }
    
    func build(in world: World, production: Double) throws {
        guard buildQueue.count > 0 else {
            return
        }
        
        var changedCity = try world.getCityWithID(buildQueue[0].ownerID)
        
        var changedBuildComponent = self
        var changedBuildQueue = buildQueue
        var itemToBuild = changedBuildQueue.removeFirst()
        
        itemToBuild.productionRemaining -= changedCity.production
        print("Added \(production) production. \(itemToBuild.productionRemaining) production remaining.")
    
        if itemToBuild.productionRemaining <= 0 {
            try itemToBuild.execute(in: world)
        } else {
            changedBuildQueue.insert(itemToBuild, at: 0)
        }
        
        changedBuildComponent.buildQueue = changedBuildQueue
        changedCity.replaceComponent(component: changedBuildComponent)
        world.replace(changedCity)
        return
    }
    
    func addToBuildQueue(_ command: BuildCommand) -> BuildComponent {
        var changedComponent = self
        changedComponent.buildQueue.append(command)
        return changedComponent
    }
    
    func step(in world: World) {
        if let owner = try? world.getCityWithID(ownerID) {
            try? build(in: world, production: owner.production)
        }
    }
}

// MARK: Commands
struct QueueBuildUnitCommand: Command, Codable {
    let unitToBuildName: String
    let title: String
    let ownerID: UUID
    
    init(ownerID: UUID, unitToBuildName: String) {
        self.ownerID = ownerID
        self.unitToBuildName = unitToBuildName
        self.title = "Build \(unitToBuildName)"
    }
    
    func execute(in world: World) throws {
        var owner = try world.getCityWithID(ownerID)
        guard let buildComponent = owner.getComponent(BuildComponent.self) else {
            throw EntityErrors.componentNotFound(componentName: "BuildComponent")
        }
        
        let buildUnitCommand = BuildUnitCommand(ownerID: ownerID, unitToBuildName: unitToBuildName)
        
        let changedBC = buildComponent.addToBuildQueue(buildUnitCommand)
        
        owner.replaceComponent(component: changedBC)
        world.replace(owner)
        return
    }
}

// Don't call this command directly, but execute it from QueueBuildUnitCommand instead.
struct BuildUnitCommand: BuildCommand, Codable {
    var ownerID: UUID
    
    let unitToBuildName: String
    let title: String
    var productionRemaining: Double
    
    var unitToBuild: (UUID, AxialCoord) -> Unit {
        return Unit.allUnits[unitToBuildName, default: Unit.nullUnit]
    }
    
    init(ownerID: UUID, unitToBuildName: String) {
        self.ownerID = ownerID
        self.productionRemaining = Unit.unitProductionRequirements[unitToBuildName, default: 9999999]
        self.unitToBuildName = unitToBuildName
        title = "Build \(unitToBuildName)"
    }
    
    func execute(in world: World) throws {
        let owner = try world.getCityWithID(ownerID)
        let newUnit = unitToBuild(owner.owningPlayerID, owner.position)
        
        world.addUnit(newUnit)
        return
    }
}

struct RemoveFromBuildQueueCommand: Command, Codable {
    var title = "Remove from build queue"
    var ownerID: UUID
    
    let commandToRemoveIndex: Int
    
    func execute(in world: World) throws {
        var city = try world.getCityWithID(ownerID)
        if var buildComponent = city.getComponent(BuildComponent.self) {
            buildComponent.buildQueue.remove(at: commandToRemoveIndex)
            city.replaceComponent(component: buildComponent)
            world.replace(city)
        }
    }
}
