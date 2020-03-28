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
    
    init(ownerID: UUID) {
        self.ownerID = ownerID
        self.population = 1
        self.savedFood = 0
        self.possibleCommands = []
    }
    
    func step(in world: World) {
        if var changedCity = try? world.getCityWithID(ownerID) {
            var changedComponent = self
            while changedComponent.savedFood >= foodForNextPopulation {
                changedComponent.population += 1
                changedComponent.savedFood = changedComponent.savedFood / 4
            }
            
            changedCity.replaceComponent(component: changedComponent)
            world.replace(changedCity)
        }
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
}
