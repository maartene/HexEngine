//
//  Unit.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

struct Unit: Entity {
    
    static var Prototypes: [Unit] = Bundle.main.decode([Unit].self, from: "units.json")
    static func getPrototype(unitName: String) -> Unit {
        if var unit = Prototypes.first(where: { $0.name == unitName }) {
            // the prototype comes with a default ID. Make sure it gets a unique ID.
            unit.assignUniqueID()
            return unit
        } else {
            fatalError("No Unit prototype with name \(unitName) found.")
        }
    }
    static func getPrototype(unitName: String, for owningPlayerID: UUID, startPosition: AxialCoord = AxialCoord.zero) -> Unit {
        var unit = getPrototype(unitName: unitName)
        unit.position = startPosition
        unit.owningPlayerID = owningPlayerID
        return unit
    }
    
    var id: UUID
    var owningPlayerID: UUID
    var position: AxialCoord
    
    let name: String
    var components = [Component]()
    
    var visibility: Int
    var actionsRemaining = 2.0
    let productionRequired: Double
    let prerequisiteTechs: [String]

    init(owningPlayer: UUID, name: String, visibility: Int = 1, productionRequired: Double, startPosition: AxialCoord = AxialCoord.zero, prerequisiteTechs: [String] = []) {
        self.id = UUID()
        self.owningPlayerID = owningPlayer
        self.name = name
        self.visibility = visibility
        self.productionRequired = productionRequired
        self.position = startPosition
        self.prerequisiteTechs = prerequisiteTechs
    }
    
    mutating func assignUniqueID() {
        id = UUID()
        components = components.map { component in
            var changedComponent = component
            changedComponent.ownerID = id
            changedComponent.possibleCommands = changedComponent.possibleCommands.map { command in
                var changedCommand = command
                changedCommand.ownerID = id
                return changedCommand
            }
            return changedComponent
        }
    }
}
