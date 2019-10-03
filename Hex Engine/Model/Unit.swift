//
//  Unit.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct Unit {
    let id: Int
    let name: String
    var movement: Int
    var position: AxialCoord
    
    static var onUnitCreate: ((Unit) -> Void)?
    static var onUnitChanged: ((Unit) -> Void)?
    
    init(id: Int, name: String, movement: Int = 2, startPosition: AxialCoord = AxialCoord.zero) {
        self.id = id
        self.name = name
        self.movement = movement
        self.position = startPosition
        
        
        Self.onUnitCreate?(self)
    }
    
    mutating func move(to position: AxialCoord) {
        self.position = position
        Self.onUnitChanged?(self)
    }
}
