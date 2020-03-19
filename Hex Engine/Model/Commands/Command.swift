//
//  Command.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

protocol Commander {
    var id: UUID { get }
    var owningPlayerID: UUID { get }
    var position: AxialCoord { get set }
}

enum CommandErrors: Error {
    case cannotExecute
    case missingTarget          // maybe move to seperate enum for TileTargettingCommands
    case illegalTarget          // maybe move to seperate enum for TileTargettingCommands
}

protocol Command {
    var title: String { get }
    var ownerID: UUID { get }
    
    func execute(in world: World) throws
    func canExecute(in world: World) -> Bool
}

extension Command {
    func execute(in world: World) throws {
        guard canExecute(in: world) else {
            throw CommandErrors.cannotExecute
        }
        
        print("Executing command: \(title) by owner with ID: \(ownerID).")
        return
    }
    
    func canExecute(in world: World) -> Bool {
        return true
    }
}

protocol BuildCommand: Command {
    var productionRemaining: Double { get set }
}

protocol TileTargettingCommand: Command {
    var targetTile: AxialCoord? { get set }
}
