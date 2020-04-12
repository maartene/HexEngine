//
//  Command.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

enum CommandErrors: Error {
    case cannotExecute
    case missingTarget          // maybe move to seperate enum for TileTargettingCommands
    case illegalTarget          // maybe move to seperate enum for TileTargettingCommands
}

protocol Command: Codable {
    var title: String { get }
    var ownerID: UUID { get set }
    
    func execute(in world: World) throws -> World
    func canExecute(in world: World) -> Bool
}

extension Command {
    func execute(in world: World) throws -> World {
        guard canExecute(in: world) else {
            throw CommandErrors.cannotExecute
        }
        
        print("Executing command: \(title) by owner with ID: \(ownerID).")
        return world
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
    func getValidTargets(in world: World) throws -> [AxialCoord]
    var hasFilter: Bool { get }
    var lensColor: SKColor { get }
}

extension TileTargettingCommand {
    var hasFilter: Bool {
        return false
    }
    
    func getValidTargets(in world: World) throws -> [AxialCoord] {
        return []
    }
    
    var lensColor: SKColor {
        return SKColor.white
    }
}
