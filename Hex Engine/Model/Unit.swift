//
//  Unit.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct Unit {
    let id = UUID()
    let owningPlayer: UUID
    let name: String
    var movement: Int
    var movementLeft: Double
    var visibility: Int
    var position: AxialCoord
    var path = [AxialCoord]()
    var possibleCommands = [Command]()
    static var onUnitCreate: ((Unit) -> Void)?
    static var onUnitChanged: ((Unit) -> Void)?
    
    init(owningPlayer: UUID, name: String, movement: Int = 2, visibility: Int = 2, startPosition: AxialCoord = AxialCoord.zero) {
        self.owningPlayer = owningPlayer
        self.name = name
        self.movement = movement
        self.movementLeft = Double(movement)
        self.visibility = visibility
        self.position = startPosition
        
        Self.onUnitCreate?(self)
    }
    
    mutating func move(to position: AxialCoord) {
        self.position = position
        Self.onUnitChanged?(self)
    }
    
    func step(hexMap: HexMap) -> Unit {
        print("step for unit \(self)")
        
        var unit = self
        unit.movementLeft = Double(unit.movement)
        
        unit.move(hexMap: hexMap)
        
        return unit
    }
    
    mutating func move(hexMap: HexMap) {
        while movementLeft > 0 && path.count > 0 {
            if path.first! == position {
                path.remove(at: 0)
            }
            if path.count > 0 {
                let nextStep = path.removeFirst()
                let tile = hexMap[nextStep]
                if tile.blocksMovement {
                    movementLeft = 0
                } else {
                    movementLeft -= tile.costToEnter
                }
                move(to: nextStep)
            }
        }
    }
    
    static func Rabbit(owningPlayer: UUID, startPosition: AxialCoord) -> Unit {
        var newRabbit = Unit(owningPlayer: owningPlayer, name: "Rabbit", movement: 2, startPosition: startPosition)
        newRabbit.possibleCommands = [BuildCityCommand(ownerID: newRabbit.id)]
        return newRabbit
    }
}
