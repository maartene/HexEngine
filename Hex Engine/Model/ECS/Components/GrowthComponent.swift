//
//  GrowthComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 28/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct GrowthComponent: Component {
    var ownerID: UUID
    
    var possibleCommands: [Command]
    
    var population: Int
    var savedFood: Double
    var foodForNextPopulation: Double {
        return 10.0 + pow(3, power: population)
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
            
            // capitals get a base extra yield
            changedComponent.yield = changedCity.isCapital ? Tile.TileYield(food: 1, production: 1, gold: 1) : Tile.TileYield()
            
            changedComponent.yield += changedComponent.workingTiles.reduce(Tile.TileYield()) { result, coord in
                result + world.getTileYield(for: coord)
            }
            // always work first tile
            changedComponent.yield += world.getTileYield(for: changedCity.position)
            
            // yield from buildings
            changedComponent.yield += yieldFromBuildings(city: changedCity)
            
            //print("Yield: \(changedComponent.yield)")
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
            
            var coordsWithinRange = HexMap.coordinatesWithinRange(from: owner.position, range: owner.visibility)
            
            // prevent the city tile from being worked (this one is always worked)
            coordsWithinRange.removeAll { coord in coord == owner.position }
            
            // for now, prioritize food
            let sortedByFood = coordsWithinRange.sorted { coord1, coord2 in world.getTileYield(for: coord1).food > world.getTileYield(for: coord2).food }
            
            changedGC.workingTiles = Array(sortedByFood.prefix(population))
            return changedGC
        } else {
            return growthComponent
        }
    }
    
    func yieldFromBuildings(city: City) -> Tile.TileYield {
        let buildingYield = city.buildings.reduce(Tile.TileYield()) { tempResult, improvement in
            improvement.updateTileYield(tempResult)
        }
        //print("buildingYield: \(buildingYield)")
        return buildingYield
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
    
    @available(*, deprecated, message: "Use '.yield.production' instead.")
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
    
    var yield: Tile.TileYield {
        if let gc = self.getComponent(GrowthComponent.self) {
            return gc.yield
        } else {
            return isCapital ? Tile.TileYield(food: 3, production: 3, gold: 3) : Tile.TileYield(food: 2, production: 2, gold: 2)
        }
    }
}

func pow(_ base: Double, power: Int) -> Double {
    assert(power >= 0)
    var result = 1.0
    for _ in 0 ..< power {
        result *= base
    }
    return result
}
