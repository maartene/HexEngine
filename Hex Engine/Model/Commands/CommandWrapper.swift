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
    
    //case addProductionCommand(value: AddProductionCommand)
    case buildCityCommand(value: BuildCityCommand)
    case moveUnitCommand(value: MoveUnitCommand)
    case queueBuildRabbitCommand(value: QueueBuildRabbitCommand)
    case nextTurnCommand(value: NextTurnCommand)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        /*case .addProductionCommand(value: let value):
            try container.encode("addProductionCommand", forKey: .type)
            try container.encode(value, forKey: .value)*/
        case .buildCityCommand(let value):
            try container.encode("buildCityCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .moveUnitCommand(let value):
            try container.encode("moveUnitCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .queueBuildRabbitCommand(let value):
            try container.encode("queueBuildRabbitCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        case .nextTurnCommand(let value):
            try container.encode("nextTurnCommand", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }

    static func wrapperFor(command: Command) throws -> CommandWrapper {
        /*if let c = command as? AddProductionCommand {
            return .addProductionCommand(value: c)
        } else */if let c = command as? BuildCityCommand {
            return .buildCityCommand(value: c)
        } else if let c = command as? MoveUnitCommand {
            return .moveUnitCommand(value: c)
        } else if let c = command as? QueueBuildRabbitCommand {
            return .queueBuildRabbitCommand(value: c)
        } else if let c = command as? NextTurnCommand {
            return .nextTurnCommand(value: c)
        } else {
            throw CommandWrapperErrors.cannotConvertCommandError
        }
    }
}