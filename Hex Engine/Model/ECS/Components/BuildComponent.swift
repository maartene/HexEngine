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
    
    var possibleCommands: [Command]
    var buildQueue = [BuildCommand]()
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        
        var possibleCommands = [Command]()
        for entry in Unit.Prototypes {
            possibleCommands.append(QueueBuildUnitCommand(ownerID: ownerID, unitToBuildName: entry.name))
        }
        
        for entry in Improvement.Prototypes {
            possibleCommands.append(QueueBuildBuildingCommand(ownerID: ownerID, buildingToBuildName: entry.title))
        }
        
        self.possibleCommands = possibleCommands
    }
    
    func build(in world: World, production: Double) throws -> World {
        guard buildQueue.count > 0 else {
            return world
        }
        var updatedWorld = world
        
        var changedCity = try updatedWorld.getCityWithID(buildQueue[0].ownerID)
        
        var changedBuildComponent = self
        var changedBuildQueue = buildQueue
        var itemToBuild = changedBuildQueue.removeFirst()
        
        itemToBuild.productionRemaining -= changedCity.yield.production
        print("Added \(production) production. \(itemToBuild.productionRemaining) production remaining.")
    
        if itemToBuild.productionRemaining <= 0 {
            updatedWorld = try itemToBuild.execute(in: updatedWorld)
        } else {
            changedBuildQueue.insert(itemToBuild, at: 0)
        }
        
        changedCity = try updatedWorld.getCityWithID(itemToBuild.ownerID)
        
        changedBuildComponent.buildQueue = changedBuildQueue
        changedCity.replaceComponent(component: changedBuildComponent)
        
        updatedWorld.replace(changedCity)
        return updatedWorld
    }
    
    func addToBuildQueue(_ command: BuildCommand) -> BuildComponent {
        var changedComponent = self
        changedComponent.buildQueue.append(command)
        return changedComponent
    }
    
    func step(in world: World) -> World {
        if let owner = try? world.getCityWithID(ownerID) {
            do {
                return try build(in: world, production: owner.yield.production)
            } catch {
                print(error)
                return world
            }
        }
        return world
    }
}

// MARK: Commands
struct QueueBuildUnitCommand: Command, Codable {
    let unitToBuildName: String
    let title: String
    var ownerID: UUID
    
    init(ownerID: UUID, unitToBuildName: String) {
        self.ownerID = ownerID
        self.unitToBuildName = unitToBuildName
        self.title = "Build \(unitToBuildName)"
    }
    
    func execute(in world: World) throws -> World {
        var owner = try world.getCityWithID(ownerID)
        guard let buildComponent = owner.getComponent(BuildComponent.self) else {
            throw EntityErrors.componentNotFound(componentName: "BuildComponent")
        }
        
        let buildUnitCommand = BuildUnitCommand(ownerID: ownerID, unitToBuildName: unitToBuildName)
        
        let changedBC = buildComponent.addToBuildQueue(buildUnitCommand)
        
        owner.replaceComponent(component: changedBC)
        var updatedWorld = world
        updatedWorld.replace(owner)
        return updatedWorld
    }
}

// Don't call this command directly, but execute it from QueueBuildUnitCommand instead.
struct BuildUnitCommand: BuildCommand, Codable {
    var ownerID: UUID
    
    let unitToBuildName: String
    let title: String
    var productionRemaining: Double
    
    init(ownerID: UUID, unitToBuildName: String) {
        self.ownerID = ownerID
        
        //self.productionRemaining = Unit.unitProductionRequirements[unitToBuildName, default: 9999999]
        self.unitToBuildName = unitToBuildName
        self.productionRemaining = Unit.getPrototype(unitName: unitToBuildName).productionRequired
        title = "Build \(unitToBuildName)"
    }
    
    func execute(in world: World) throws -> World {
        let owner = try world.getCityWithID(ownerID)
        let newUnit = Unit.getPrototype(unitName: unitToBuildName, for: owner.owningPlayerID, startPosition: owner.position)
        
        var updatedWorld = world
        updatedWorld.addUnit(newUnit)
        return updatedWorld
    }
}

struct RemoveFromBuildQueueCommand: Command, Codable {
    var title = "Remove from build queue"
    var ownerID: UUID
    
    let commandToRemoveIndex: Int
    
    func execute(in world: World) throws -> World {
        var city = try world.getCityWithID(ownerID)
        if var buildComponent = city.getComponent(BuildComponent.self) {
            buildComponent.buildQueue.remove(at: commandToRemoveIndex)
            city.replaceComponent(component: buildComponent)
            var updatedWorld = world
            updatedWorld.replace(city)
            return updatedWorld
        }
        return world
    }
}

struct QueueBuildBuildingCommand: Command, Codable {
    let buildingToBuildName: String
    let title: String
    var ownerID: UUID
    
    init(ownerID: UUID, buildingToBuildName: String) {
        self.ownerID = ownerID
        self.buildingToBuildName = buildingToBuildName
        self.title = "Build \(buildingToBuildName)"
    }
    
    func execute(in world: World) throws -> World {
        var owner = try world.getCityWithID(ownerID)
        guard let buildComponent = owner.getComponent(BuildComponent.self) else {
            throw EntityErrors.componentNotFound(componentName: "BuildComponent")
        }
        
        let buildBuildingCommand = BuildBuildingCommand(ownerID: ownerID, buildingToBuildName: buildingToBuildName)
        
        let changedBC = buildComponent.addToBuildQueue(buildBuildingCommand)
        
        owner.replaceComponent(component: changedBC)
        var updatedWorld = world
        updatedWorld.replace(owner)
        return updatedWorld
    }
}

// Don't call this command directly, but execute it from QueueBuildBuildingCommand instead.
struct BuildBuildingCommand: BuildCommand, Codable {
    var ownerID: UUID
    
    let buildingToBuildName: String
    let title: String
    var productionRemaining: Double
    
    init(ownerID: UUID, buildingToBuildName: String) {
        self.ownerID = ownerID
        
        //self.productionRemaining = Unit.unitProductionRequirements[unitToBuildName, default: 9999999]
        self.buildingToBuildName = buildingToBuildName
        
        self.productionRemaining = Improvement.getPrototype(title: buildingToBuildName).requiredProduction
        title = "Build \(buildingToBuildName)"
    }
    
    func execute(in world: World) throws -> World {
        var owner = try world.getCityWithID(ownerID)
        let newBuilding = Improvement.getProtype(title: buildingToBuildName, for: ownerID)
        owner.buildings.append(newBuilding)
        var updatedWorld = world
        updatedWorld.replace(owner)
        return updatedWorld
    }
}
