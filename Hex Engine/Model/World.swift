//
//  World.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

enum IDArrayError: Error {
    case indexOutOfBounds
}

struct World {
    
    var hexMap: HexMap
    private var units = [Unit]()
    
    init(width: Int, height: Int, hexMapFactory: (Int, Int) -> HexMap) {
        self.hexMap = hexMapFactory(width, height)
        
        units.append(Unit(id: 0, name: "Rabbit", movement: 2, startPosition: AxialCoord(q: 1, r: 2)))
    }
    
    func getUnitsOnTile(_ tile: AxialCoord) -> [Unit] {
        return units.filter { unit in
            unit.position.q == tile.q && unit.position.r == tile.r
        }
    }
    
    func getUnitWithID(_ id: Int) throws -> Unit {
        let result = units.first { unit in
            unit.id == id
        }
        if result == nil {
            throw IDArrayError.indexOutOfBounds
        } else {
            return result!
        }
        
    }
    
    var allUnits: [Unit] {
        return units
    }
}
