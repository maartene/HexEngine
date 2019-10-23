//
//  Command.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

protocol Commander {
    var id: Int { get }
    var position: AxialCoord { get set }
}

enum CommandErrors: Error {
    case cannotExecute
}

protocol Command {
    var title: String { get }
    var ownerID: Int { get}
    
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
