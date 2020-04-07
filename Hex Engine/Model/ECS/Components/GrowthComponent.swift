//
//  GrowthComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 28/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct GrowthComponent: Component {
    let ownerID: UUID
    
    var possibleCommands: [Command]
    
    var population: Int
    var savedFood: Double
    var foodForNextPopulation: Double {
        return Double(10 + population * population)
    }
    
    var yield = Tile.TileYield()
    
    var workingTiles = [AxialCoord]()
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        self.population = 1
        self.savedFood = 0
        self.possibleCommands = []
    }
    
    func step(in world: World) -> World {
        if var changedCity = try? world.getCityWithID(ownerID) {
            var changedComponent = distributePopulation(self, in: world)
            
            
            changedComponent.yield = changedCity.isCapital ? Tile.TileYield(food: 1, production: 1, gold: 1) : Tile.TileYield()
            changedComponent.yield += changedComponent.workingTiles.reduce(Tile.TileYield()) { result, coord in
                result + getTileYield(for: coord, in: world)
            }
//            print("Yield: \(yield)")
            changedComponent.savedFood += yield.food
            
            while changedComponent.savedFood >= foodForNextPopulation {
                changedComponent.population += 1
                changedComponent.savedFood = changedComponent.savedFood / 4
            }
            
            changedCity.replaceComponent(component: changedComponent)
            var updatedWorld = world
            updatedWorld.replace(changedCity)
            return updatedWorld
        }
        return world
    }
    
    func distributePopulation(_ growthComponent: GrowthComponent, in world: World) -> GrowthComponent {
        if let owner = try? world.getCityWithID(ownerID) {
            var changedGC = growthComponent
            
            let coordsWithinRange = HexMap.coordinatesWithinRange(from: owner.position, range: owner.visibility)
            // for now, prioritize food
            let sortedByFood = coordsWithinRange.sorted { coord1, coord2 in getTileYield(for: coord1, in: world).food > getTileYield(for: coord2, in: world).food }
            
            changedGC.workingTiles = Array(sortedByFood.prefix(population))
            return changedGC
        } else {
            return growthComponent
        }
    }
    
    func getTileYield(for coord: AxialCoord, in world: World) -> Tile.TileYield {
        let baseYield = world.hexMap[coord].baseTileYield
        var production = baseYield.production
        var food = baseYield.food
        var gold = baseYield.gold
        
        return Tile.TileYield(food: food, production: production, gold: gold)
    }
}

extension City {
    var population: Int {
        if let gc = self.getComponent(GrowthComponent.self) {
            return gc.population
        } else {
            return 5
        }
    }
    
    var production: Double {
        if let gc = self.getComponent(GrowthComponent.self) {
            return gc.yield.production
        } else {
            return 5
        }
    }
    
    var savedFood: Double {
        if let gc = self.getComponent(GrowthComponent.self) {
            return gc.savedFood
        } else {
            return 1
        }
    }
}
