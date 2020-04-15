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

enum CommandWrapper: Codable {
    enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    case foundCityCommand(value: FoundCityCommand)
    case moveUnitCommand(value: MoveUnitCommand)
    case queueBuildUnitCommand(value: QueueBuildUnitCommand)
    case queueBuildBuildingCommand(value: QueueBuildBuildingCommand)
    case buildUnitCommand(value: BuildUnitCommand)
    case buildBuildingCommand(value: BuildBuildingCommand)
    case attackTileCommand(value: AttackCommand)
    case removeFromBuildQueueCommand(value: RemoveFromBuildQueueCommand)
    case buildTileImprovementCommand(value: BuildTileImprovementCommand)
    case enableAutoExploreCommand(value: EnableAutoExploreCommand)
    case disableAutoExploreCommand(value: DisableAutoExploreCommand)
    
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
        case .buildUnitCommand(let value):
            try container.encode("buildUnitCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .attackTileCommand(let value):
            try container.encode("attackTileCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .removeFromBuildQueueCommand(let value):
            try container.encode("removeFromBuildQueueCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .buildTileImprovementCommand(let value):
            try container.encode("buildTileImprovementCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .buildBuildingCommand(let value):
            try container.encode("buildBuildingCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .queueBuildBuildingCommand(let value):
            try container.encode("queueBuildBuildingCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .enableAutoExploreCommand(let value):
            try container.encode("enableAutoExploreCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .disableAutoExploreCommand(let value):
            try container.encode("disableAutoExploreCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        switch type {
        case "foundCityCommand":
            let value = try values.decode(FoundCityCommand.self, forKey: .value)
            self = .foundCityCommand(value: value)
        case "moveUnitCommand":
            let value = try values.decode(MoveUnitCommand.self, forKey: .value)
            self = .moveUnitCommand(value: value)
        case "queueBuildUnitCommand":
            let value = try values.decode(QueueBuildUnitCommand.self, forKey: .value)
            self = .queueBuildUnitCommand(value: value)
        case "buildUnitCommand":
            let value = try values.decode(BuildUnitCommand.self, forKey: .value)
            self = .buildUnitCommand(value: value)
        case "attackTileCommand":
            let value = try values.decode(AttackCommand.self, forKey: .value)
            self = .attackTileCommand(value: value)
        case "removeFromBuildQueueCommand":
            let value = try values.decode(RemoveFromBuildQueueCommand.self, forKey: .value)
            self = .removeFromBuildQueueCommand(value: value)
        case "buildTileImprovementCommand":
            let value = try values.decode(BuildTileImprovementCommand.self, forKey: .value)
            self = .buildTileImprovementCommand(value: value)
        case "buildBuildingCommand":
            let value = try values.decode(BuildBuildingCommand.self, forKey: .value)
            self = .buildBuildingCommand(value: value)
        case "queueBuildBuildingCommand":
            let value = try values.decode(QueueBuildBuildingCommand.self, forKey: .value)
            self = .queueBuildBuildingCommand(value: value)
        case "enableAutoExploreCommand":
            let value = try values.decode(EnableAutoExploreCommand.self, forKey: .value)
            self = .enableAutoExploreCommand(value: value)
        case "disableAutoExploreCommand":
            let value = try values.decode(DisableAutoExploreCommand.self, forKey: .value)
            self = .disableAutoExploreCommand(value: value)
            
        default:
            throw CommandWrapperErrors.cannotConvertCommandError
        }
    }

    static func wrapperFor(command: Command) throws -> CommandWrapper {
        if let c = command as? FoundCityCommand {
            return .foundCityCommand(value: c)
        } else if let c = command as? MoveUnitCommand {
            return .moveUnitCommand(value: c)
        } else if let c = command as? QueueBuildUnitCommand {
            return .queueBuildUnitCommand(value: c)
        } else if let c = command as? BuildUnitCommand {
            return .buildUnitCommand(value: c)
        } else if let c = command as? AttackCommand {
            return .attackTileCommand(value: c)
        } else if let c = command as? RemoveFromBuildQueueCommand {
            return .removeFromBuildQueueCommand(value: c)
        } else if let c = command as? BuildTileImprovementCommand {
            return .buildTileImprovementCommand(value: c)
        } else if let c = command as? BuildBuildingCommand {
            return .buildBuildingCommand(value: c)
        } else if let c = command as? QueueBuildBuildingCommand {
            return .queueBuildBuildingCommand(value: c)
        } else if let c = command as? EnableAutoExploreCommand {
            return .enableAutoExploreCommand(value: c)
        } else if let c = command as? DisableAutoExploreCommand {
            return .disableAutoExploreCommand(value: c)
        } else {
            throw CommandWrapperErrors.cannotConvertCommandError
        }
    }
    
    func command() throws -> Command {
        switch self {
        case .foundCityCommand(let value):
            return value
        case .moveUnitCommand(let value):
            return value
        case .queueBuildUnitCommand(let value):
            return value
        case .buildUnitCommand(let value):
            return value
        case .attackTileCommand(let value):
            return value
        case .removeFromBuildQueueCommand(let value):
            return value
        case .buildTileImprovementCommand(let value):
            return value
        case .buildBuildingCommand(let value):
            return value
        case .queueBuildBuildingCommand(let value):
            return value
        case .enableAutoExploreCommand(let value):
            return value
        case .disableAutoExploreCommand(let value):
            return value
        }
    }
}
