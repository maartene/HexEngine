//
//  CommandWrapper.swift
//  Hex Engine
//
//  Created by Maarten Engels on 02/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

enum CommandWrapperErrors: Error {
    case cannotConvertCommandError
}

enum CommandWrapper: Encodable {
    enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    case foundCityCommand(value: FoundCityCommand)
    case moveUnitCommand(value: MoveUnitCommand)
    case queueBuildUnitCommand(value: QueueBuildUnitCommand)
    case nextTurnCommand(value: NextTurnCommand)
    case attackTileCommand(value: AttackCommand)
    case removeFromBuildQueueCommand(value: RemoveFromBuildQueueCommand)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .foundCityCommand(let value):
            try container.encode("foundCityCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .moveUnitCommand(let value):
            try container.encode("moveUnitCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .queueBuildUnitCommand(let value):
            try container.encode("queueBuildUnitCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .nextTurnCommand(let value):
            try container.encode("nextTurnCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .attackTileCommand(let value):
            try container.encode("attackTileCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .removeFromBuildQueueCommand(let value):
            try container.encode("removeFromBuildQueueCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }

    static func wrapperFor(command: Command) throws -> CommandWrapper {
        if let c = command as? FoundCityCommand {
            return .foundCityCommand(value: c)
        } else if let c = command as? MoveUnitCommand {
            return .moveUnitCommand(value: c)
        } else if let c = command as? QueueBuildUnitCommand {
            return .queueBuildUnitCommand(value: c)
        } else if let c = command as? NextTurnCommand {
            return .nextTurnCommand(value: c)
        } else if let c = command as? AttackCommand {
            return .attackTileCommand(value: c)
        } else if let c = command as? RemoveFromBuildQueueCommand {
            return .removeFromBuildQueueCommand(value: c)
        } else {
            throw CommandWrapperErrors.cannotConvertCommandError
        }
    }
}
