//
//  Builder.swift
//  Hex Engine
//
//  Created by Maarten Engels on 21/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

protocol Builder: Commander {
    var possibleCommands: [BuildCommand] { get }
    var buildQueue: [BuildCommand] { get set }
    
    func build(in world: World, production: Double) throws -> World
    func addToBuildQueue(_ command: BuildCommand) -> Builder
}

extension Builder {
    func build(in world: World, production: Double) throws -> World {
        guard buildQueue.count > 0 else {
            return world
        }
        
        var newWorld = world
        var newBuilder = try world.getCityWithID(buildQueue[0].ownerID)
        
        var newBuildQueue = newBuilder.buildQueue
        var itemToBuild = newBuildQueue.removeFirst()
        
        itemToBuild.productionRemaining -= production
        print("Added \(production) production. \(itemToBuild.productionRemaining) production remaining.")
    
        if itemToBuild.productionRemaining <= 0 {
            newWorld = (try? itemToBuild.execute(in: newWorld)) ?? world
        } else {
            newBuildQueue.insert(itemToBuild, at: 0)
        }
        
        newBuilder.buildQueue = newBuildQueue
        newWorld.replaceBuilder(newBuilder)
        return newWorld
    }
    
    func addToBuildQueue(_ command: BuildCommand) -> Builder {
        var newBuilder = self
        newBuilder.buildQueue.append(command)
        return newBuilder
    }
}
