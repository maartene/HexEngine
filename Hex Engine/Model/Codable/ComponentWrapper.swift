//
//  ComponentWrapper.swift
//  Hex Engine
//
//  Created by Maarten Engels on 21/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

enum ComponentWrapperErrors: Error {
    case cannotConvertComponentError
}

enum ComponentWrapper: Codable {
    
    enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    case attackComponent(value: AttackComponent)
    case buildComponent(value: BuildComponent)
    case healthComponent(value: HealthComponent)
    case movementComponent(value: MovementComponent)
    case settlerComponent(value: SettlerComponent)
    case growthComponent(value: GrowthComponent)
    case autoExploreComponent(value: AutoExploreComponent)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .attackComponent(let value):
            try container.encode("attackComponent", forKey: .type)
            try container.encode(value, forKey: .value)
        case .buildComponent(let value):
            try container.encode("buildComponent", forKey: .type)
            try container.encode(value, forKey: .value)
        case .healthComponent(let value):
            try container.encode("healthComponent", forKey: .type)
            try container.encode(value, forKey: .value)
        case .movementComponent(let value):
            try container.encode("movementComponent", forKey: .type)
            try container.encode(value, forKey: .value)
        case .settlerComponent(let value):
            try container.encode("settlerComponent", forKey: .type)
            try container.encode(value, forKey: .value)
        case .growthComponent(let value):
            try container.encode("growthComponent", forKey: .type)
            try container.encode(value, forKey: .value)
        case .autoExploreComponent(let value):
            try container.encode("autoExploreComponent", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        switch type {
        case "attackComponent":
            let value = try values.decode(AttackComponent.self, forKey: .value)
            self = .attackComponent(value: value)
        case "buildComponent":
            let value = try values.decode(BuildComponent.self, forKey: .value)
            self = .buildComponent(value: value)
        case "healthComponent":
            let value = try values.decode(HealthComponent.self, forKey: .value)
            self = .healthComponent(value: value)
        case "movementComponent":
            let value = try values.decode(MovementComponent.self, forKey: .value)
            self = .movementComponent(value: value)
        case "settlerComponent":
            let value = try values.decode(SettlerComponent.self, forKey: .value)
            self = .settlerComponent(value: value)
        case "growthComponent":
            let value = try values.decode(GrowthComponent.self, forKey: .value)
            self = .growthComponent(value: value)
        case "autoExploreComponent":
            let value = try values.decode(AutoExploreComponent.self, forKey: .value)
            self = .autoExploreComponent(value: value)
        default:
            throw ComponentWrapperErrors.cannotConvertComponentError
        }
    }
    
    static func wrapperFor(_ component: Component) throws -> ComponentWrapper {
        if let c = component as? AttackComponent {
            return .attackComponent(value: c)
        } else if let c = component as? BuildComponent {
            return .buildComponent(value: c)
        } else if let c = component as? HealthComponent {
            return .healthComponent(value: c)
        } else if let c = component as? MovementComponent {
            return .movementComponent(value: c)
        } else if let c = component as? SettlerComponent {
            return .settlerComponent(value: c)
        } else if let c = component as? GrowthComponent {
            return .growthComponent(value: c)
        } else if let c = component as? AutoExploreComponent {
            return .autoExploreComponent(value: c)
        } else {
            throw ComponentWrapperErrors.cannotConvertComponentError
        }
    }
    
    func component() throws -> Component {
        switch self {
        case .attackComponent(let component):
            return component
        case .buildComponent(let component):
            return component
        case .healthComponent(let component):
            return component
        case .movementComponent(let component):
            return component
        case .settlerComponent(let component):
            return component
        case .growthComponent(let component):
            return component
        case .autoExploreComponent(let component):
            return component
        }
    }
    
}
