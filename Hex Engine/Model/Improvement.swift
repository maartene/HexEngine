//
//  Improvement.swift
//  Hex Engine
//
//  Created by Maarten Engels on 10/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct Improvement: Codable {
    
    static var Prototypes = Bundle.main.decode([Improvement].self, from: "improvements.json")
    static func getProtype(title: String, for ownerID: UUID) -> Improvement {
        if let prototype = Prototypes.first(where: { $0.title == title }) {
            return Improvement(title: prototype.title, ownerID: ownerID, requiredProduction: prototype.requiredProduction, extraTileYield: prototype.extraTileYield, unique: prototype.unique)
        } else {
            fatalError("No prototype with title \(title) found in Prototypes array.")
        }
    }
    
    static func getPrototype(title: String) -> Improvement {
        if let prototype = Prototypes.first(where: { $0.title == title }) {
            return prototype
        } else {
            fatalError("No prototype with title \(title) found in Prototypes array.")
        }
    }
    
    let title: String
    let ownerID: UUID
    let requiredProduction: Double
    let extraTileYield: Tile.TileYield
    
    let unique: Bool
    
    func canBuild(in world: World) -> Bool {
        do {
            let owner = try world.getCityWithID(ownerID)
            if unique == false {
                return owner.buildings.contains(where: { $0.title == title }) == false
            } else {
                return world.allCities.reduce(true) { currentResult, city in
                    return currentResult && city.buildings.contains(where: { building in
                        building.title == title
                    })
                }
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func updateTileYield(_ yield: Tile.TileYield) -> Tile.TileYield {
        return yield + extraTileYield
    }
}
