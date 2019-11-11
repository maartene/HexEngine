//
//  City.swift
//  Hex Engine
//
//  Created by Maarten Engels on 23/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct City: Builder {
    var possibleCommands = [Command]()
    
    var buildQueue = [BuildCommand]()
    
    let id = UUID()
    
    var position: AxialCoord
    
    let name: String
    
    static var onCityCreate: ((City) -> Void)?
    
    init(name: String, position: AxialCoord) {
        self.name = name
        self.position = position
        possibleCommands.append(QueueBuildRabbitCommand(ownerID: id))
        
        Self.onCityCreate?(self)
    }
}
