//
//  City.swift
//  Hex Engine
//
//  Created by Maarten Engels on 23/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct City: Entity {
    let id = UUID()
    var owningPlayerID: UUID
    var position: AxialCoord
    
    let name: String
    var components = [Component]()
    var visibility = 2
    
    static var onCityCreate: ((City) -> Void)?
    
    init(owningPlayer: UUID, name: String, position: AxialCoord) {
        self.owningPlayerID = owningPlayer
        self.name = name
        self.position = position
        
        components = [BuildComponent(ownerID: id)]
        
        Self.onCityCreate?(self)
    }
}
