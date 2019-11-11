//
//  Builder.swift
//  Hex Engine
//
//  Created by Maarten Engels on 21/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

protocol Builder: Commander {
    var possibleCommands: [Command] { get }
    var buildQueue: [BuildCommand] { get set }
    
    func build(in world: World, production: Double) throws
    func addToBuildQueue(_ command: BuildCommand) -> Builder
}

extension Builder {
    func build(in world: World, production: Double) throws {
        guard buildQueue.count > 0 else {
            return
        }
        
        var newBuilder = try world.getCityWithID(buildQueue[0].ownerID)
        
        var newBuildQueue = newBuilder.buildQueue
        var itemToBuild = newBuildQueue.removeFirst()
        
        itemToBuild.productionRemaining -= production
        print("Added \(production) production. \(itemToBuild.productionRemaining) production remaining.")
    
        if itemToBuild.productionRemaining <= 0 {
            try itemToBuild.execute(in: world)
        } else {
            newBuildQueue.insert(itemToBuild, at: 0)
        }
        
        newBuilder.buildQueue = newBuildQueue
        world.replaceBuilder(newBuilder)
        return
    }
    
    func addToBuildQueue(_ command: BuildCommand) -> Builder {
        var newBuilder = self
        newBuilder.buildQueue.append(command)
        return newBuilder
    }
}
