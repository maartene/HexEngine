//
//  WorldBox.swift
//  Hex Engine
//
//  Created by Maarten Engels on 07/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import Combine

final class WorldBox: ObservableObject {
    @Published var world: World
    @Published var isUpdating = false
    
    init(world: World) {
        self.world = world
    }
    
    func nextTurn() {
        var updatedWorld = world
        isUpdating = true
        DispatchQueue.global().async {
            updatedWorld = self.world.nextTurn()
            
            DispatchQueue.main.async {
                print("Update done!")
                self.world = updatedWorld
                self.isUpdating = false
            }
        }
    }
    
    func executeCommand(_ command: Command) {
        let updatedWorld = world.executeCommand(command)
        world = updatedWorld.updateVisibilityForPlayer(player: updatedWorld.currentPlayer!)
    }
}
