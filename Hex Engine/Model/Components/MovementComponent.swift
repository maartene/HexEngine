//
//  MovementComponent.swift
//  Hex Engine
//
//  Created by Maarten Engels on 17/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit

struct MovementComponent : Component {
    
    let owner: Entity
    let movementCosts: [Tile: Double]
    let movement: Double
    let remainingMovement: Double
    
    // patchfinding stuff
    var pathfindingGraph = GKGraph()                            // every entity with a movement component has its own pathfinding graph
    var nodeToTileCoordMap = [GKGraphNode: AxialCoord]()
    var tileCoordToNodeMap = [AxialCoord : GKGraphNode]()
    var path = [AxialCoord]()
    
    init(owner: Entity, movementCosts: [Tile: Double] = Tile.defaultCostsToEnter, movement: Double = 2) {
        self.owner = owner
        self.movementCosts = movementCosts
        self.movement = movement
        self.remainingMovement = movement
    }
    
    
    
}


// MARK: Commands

