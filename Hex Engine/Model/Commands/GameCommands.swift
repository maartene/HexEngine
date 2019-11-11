//
//  GameCommands.swift
//  Hex Engine
//
//  Created by Maarten Engels on 02/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct NextTurnCommand: Command, Codable {
    let title = "Next turn"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        world.nextTurn()
    }
}
