//
//  City.swift
//  Hex Engine
//
//  Created by Maarten Engels on 23/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct City: Entity {
    let id: UUID
    var owningPlayerID: UUID
    var position: AxialCoord
    
    let name: String
    var components = [Component]()
    var visibility = 2
    var isCapital = false
    
    init(owningPlayer: UUID, name: String, position: AxialCoord, isCapital: Bool = false) {
        self.id = UUID()
        self.owningPlayerID = owningPlayer
        self.name = name
        self.position = position
        self.isCapital = isCapital
        
        components = [BuildComponent(ownerID: id), GrowthComponent(ownerID: id)]
    }
}
