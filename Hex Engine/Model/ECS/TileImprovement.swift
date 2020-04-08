//
//  TileImprovement.swift
//  Hex Engine
//
//  Created by Maarten Engels on 08/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct TileImprovement: Codable {
    enum TileImprovementErrors: Error {
        case tileAlreadyOccupiedError
        case unknownTileImprovement
    }
    
    let title: String
    let position: AxialCoord
    let extraTileYield: Tile.TileYield
    
    func updateTileYield(_ yield: Tile.TileYield) -> Tile.TileYield {
        return yield + extraTileYield
    }
    
    static func Farm(position: AxialCoord) -> TileImprovement{
        return TileImprovement(title: "Farm", position: position, extraTileYield: Tile.TileYield(food: 2, production: 0, gold: 0))
    }
    
    static func Mine(position: AxialCoord) -> TileImprovement {
        return TileImprovement(title: "Mine", position: position, extraTileYield: Tile.TileYield(food: 0, production: 1, gold: 1))
    }
    
    static func Temple(position: AxialCoord) -> TileImprovement {
        return TileImprovement(title: "Temple", position: position, extraTileYield: Tile.TileYield(food: 0, production: 0, gold: 2))
    }
    
    static func Camp(position: AxialCoord) -> TileImprovement {
        return TileImprovement(title: "Camp", position: position, extraTileYield: Tile.TileYield(food: 1, production: 0, gold: 1))
    }
    
    static let allTileImprovements = ["Farm": Farm, "Mine": Mine, "Temple": Temple, "Camp": Camp]
    static let tileImprovementEnergyCost = ["Farm": 2.0, "Mine": 3.0, "Temple": 4.0, "Camp": 4.0]
}
