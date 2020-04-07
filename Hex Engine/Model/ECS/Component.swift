//
//  Component.swift
//  Hex Engine
//
//  Created by Maarten Engels on 17/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

protocol Component: Codable {
    var ownerID: UUID { get }
    var possibleCommands: [Command] { get }
    
    func step(in world: World) -> World
}
