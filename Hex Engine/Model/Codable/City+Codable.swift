//
//  City+Codable.swift
//  Hex Engine
//
//  Created by Maarten Engels on 21/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

extension City: Codable {
    enum CodingKeys: CodingKey {
        case id
        case owningPlayerID
        case position
        case name
        case components
        case visibility
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(owningPlayerID, forKey: .owningPlayerID)
        try container.encode(position, forKey: .position)
        try container.encode(name, forKey: .name)
        
        let wrappedComponents = components.compactMap { component in
            try? ComponentWrapper.wrapperFor(component)
        }
        try container.encode(wrappedComponents, forKey: .components)
        
        try container.encode(visibility, forKey: .visibility)
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        owningPlayerID = try values.decode(UUID.self, forKey: .owningPlayerID)
        position = try values.decode(AxialCoord.self, forKey: .position)
        name = try values.decode(String.self, forKey: .name)
        let wrappedComponents = try values.decode([ComponentWrapper].self, forKey: .components)
        components = wrappedComponents.compactMap { try? $0.component() }
        visibility = try values.decode(Int.self, forKey: .visibility)
    }
}
