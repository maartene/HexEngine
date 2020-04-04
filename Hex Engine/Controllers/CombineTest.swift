//
//  CombineTest.swift
//  Hex Engine
//
//  Created by Maarten Engels on 04/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import Combine

struct CombineTest {
    
    var cancellables = Set<AnyCancellable>()
    //var world: World
    
    init(world: World) {
        world.$units.sink(receiveCompletion: { completion in
            print("Complete!")
        }, receiveValue: { unitsDict in
            for unit in unitsDict.values {
                print("Position for unit: \(unit.name) (\(unit.id): \(unit.position)")
            }
            }).store(in: &cancellables)
    }
    
}
