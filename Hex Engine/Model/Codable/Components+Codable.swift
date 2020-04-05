//
//  Components+Codable.swift
//  Hex Engine
//
//  Extensions for all concrete components to conform to `Codable`
//
//  Created by Maarten Engels on 21/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

extension AttackComponent {
    enum CodingKeys: CodingKey {
        case ownerID
        case possibleCommands
        case attackPower
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerID, forKey: .ownerID)
        
        let wrappedPossibleCommands = possibleCommands.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedPossibleCommands, forKey: .possibleCommands)
        
        try container.encode(attackPower, forKey: .attackPower)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerID = try values.decode(UUID.self, forKey: .ownerID)
        attackPower = try values.decode(Double.self, forKey: .attackPower)
        let wrappedPossibleCommands = try values.decode([CommandWrapper].self, forKey: .possibleCommands)
        possibleCommands = wrappedPossibleCommands.compactMap { try? $0.command() }
    }
}

extension BuildComponent {
    enum CodingKeys: CodingKey {
        case ownerID
        case possibleCommands
        case buildQueue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerID, forKey: .ownerID)
        
        let wrappedPossibleCommands = possibleCommands.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedPossibleCommands, forKey: .possibleCommands)
        
        let wrappedBuildQueue = buildQueue.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedBuildQueue, forKey: .buildQueue)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerID = try values.decode(UUID.self, forKey: .ownerID)
        
        let wrappedPossibleCommands = try values.decode([CommandWrapper].self, forKey: .possibleCommands)
        possibleCommands = wrappedPossibleCommands.compactMap { try? $0.command() }
        
        let wrappedBuildQueue = try values.decode([CommandWrapper].self, forKey: .buildQueue)
        buildQueue = wrappedBuildQueue.compactMap { try? $0.command() as? BuildCommand }
    }
}

extension HealthComponent {
    enum CodingKeys: CodingKey {
        case ownerID
        case possibleCommands
        case defencePower
        case maxHitPoints
        case currentHitPoints
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerID, forKey: .ownerID)
        
        let wrappedPossibleCommands = possibleCommands.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedPossibleCommands, forKey: .possibleCommands)
        
        try container.encode(defencePower, forKey: .defencePower)
        try container.encode(maxHitPoints, forKey: .maxHitPoints)
        try container.encode(currentHitPoints, forKey: .currentHitPoints)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerID = try values.decode(UUID.self, forKey: .ownerID)
        
        let wrappedPossibleCommands = try values.decode([CommandWrapper].self, forKey: .possibleCommands)
        possibleCommands = wrappedPossibleCommands.compactMap { try? $0.command() }
        
        defencePower = try values.decode(Double.self, forKey: .defencePower)
        maxHitPoints = try values.decode(Double.self, forKey: .maxHitPoints)
        currentHitPoints = try values.decode(Double.self, forKey: .currentHitPoints)
    }
}

extension MovementComponent {
    enum CodingKeys: CodingKey {
        case ownerID
        case movementCosts
        case path
        case possibleCommands
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerID, forKey: .ownerID)
        try container.encode(movementCosts, forKey: .movementCosts)
        try container.encode(path, forKey: .path)
        
        let wrappedPossibleCommands = possibleCommands.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedPossibleCommands, forKey: .possibleCommands)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerID = try values.decode(UUID.self, forKey: .ownerID)
        
        movementCosts = try values.decode([Tile: Double].self, forKey: .movementCosts)
        path = try values.decode([AxialCoord].self, forKey: .path)
        
        let wrappedPossibleCommands = try values.decode([CommandWrapper].self, forKey: .possibleCommands)
        possibleCommands = wrappedPossibleCommands.compactMap { try? $0.command() }
    }
}

extension SettlerComponent {
    enum CodingKeys: CodingKey {
        case ownerID
        case possibleCommands
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerID, forKey: .ownerID)
        
        let wrappedPossibleCommands = possibleCommands.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedPossibleCommands, forKey: .possibleCommands)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerID = try values.decode(UUID.self, forKey: .ownerID)
        let wrappedPossibleCommands = try values.decode([CommandWrapper].self, forKey: .possibleCommands)
        possibleCommands = wrappedPossibleCommands.compactMap { try? $0.command() }
    }
}

extension GrowthComponent {
    enum CodingKeys: CodingKey {
        case ownerID
        case population
        case savedFood
        case possibleCommands
        case workedTiles
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerID, forKey: .ownerID)
        try container.encode(population, forKey: .population)
        try container.encode(savedFood, forKey: .savedFood)
        
        let wrappedPossibleCommands = possibleCommands.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedPossibleCommands, forKey: .possibleCommands)
        
        try container.encode(workingTiles, forKey: .workedTiles)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerID = try values.decode(UUID.self, forKey: .ownerID)
        population = try values.decode(Int.self, forKey: .population)
        savedFood = try values.decode(Double.self, forKey: .savedFood)
        
        let wrappedPossibleCommands = try values.decode([CommandWrapper].self, forKey: .possibleCommands)
        possibleCommands = wrappedPossibleCommands.compactMap { try? $0.command() }
        
        workingTiles = try values.decode([AxialCoord].self, forKey: .workedTiles)
    }
}

extension AutoExploreComponent {
    enum CodingKeys: CodingKey {
        case ownerID
        case active
        case possibleCommands
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ownerID, forKey: .ownerID)
        try container.encode(active, forKey: .active)
        
        let wrappedPossibleCommands = possibleCommands.compactMap { command in try? CommandWrapper.wrapperFor(command: command) }
        try container.encode(wrappedPossibleCommands, forKey: .possibleCommands)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerID = try values.decode(UUID.self, forKey: .ownerID)
        active = try values.decode(Bool.self, forKey: .active)
        
        let wrappedPossibleCommands = try values.decode([CommandWrapper].self, forKey: .possibleCommands)
        possibleCommands = wrappedPossibleCommands.compactMap { try? $0.command() }
    }
}
