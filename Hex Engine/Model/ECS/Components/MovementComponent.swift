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
    let ownerID: UUID
    let movementCosts: [Tile: Double]
    
    // pathfinding stuff
    var pathfindingGraph = GKGraph()                            // every entity with a movement component has its own pathfinding graph
//    var nodeToTileCoordMap = [HexGraphNode: AxialCoord]()
    var tileCoordToNodeMap = [AxialCoord : HexGraphNode]()
    var path = [AxialCoord]()
    
    let possibleCommands: [Command]
    
    init(ownerID: UUID, movementCosts: [Tile: Double] = Tile.defaultCostsToEnter) {
        self.ownerID = ownerID
        self.movementCosts = movementCosts
        
        self.possibleCommands = [MoveUnitCommand(ownerID: ownerID, targetTile: nil)]
    }
    
    func move(in world: World) throws -> Unit {
        var owner = try world.getUnitWithID(ownerID)
        var updatedComponent = self
        
        while owner.actionsRemaining > 0 && updatedComponent.path.count > 0 {
            if updatedComponent.path.first! == owner.position {
                updatedComponent.path.remove(at: 0)
            }
            if updatedComponent.path.count > 0 {
                let nextStep = updatedComponent.path.removeFirst()
                let tile = world.hexMap[nextStep]
                if movementCosts[tile, default: -1] < 0 {
                    owner.actionsRemaining = 0
                } else {
                    owner.actionsRemaining -= updatedComponent.movementCosts[tile, default: 0]
                }
                owner.position = nextStep
            }
        }
        owner.replaceComponent(component: updatedComponent)
        return owner
    }
    
    func step(in world: World) {
        /*var attempts = 0
        while path.count == 0 && attempts < 5{
            // find a new target
            let targetTile = world.hexMap.getTileCoordinates().randomElement()!
            
            world.executeCommand(MoveUnitCommand(ownerID: ownerID, targetTile: targetTile))
            attempts += 1
        }*/
        //if let unit = try? world.getUnitWithID(ownerID) {
            //if let updatedUnit = try? unit.getComponent(MovementComponent.self)!.move(in: world) {
            if let updatedUnit = try? move(in: world) {
                world.replace(updatedUnit)
            }
        //}
    }
    
}

// MARK: Commands
struct MoveUnitCommand: TileTargettingCommand, Codable {
    let title: String = "Move"
    
    var ownerID: UUID
    
    var targetTile: AxialCoord?
    
    func execute(in world: World) throws {
        var owner = try world.getUnitWithID(ownerID)
        guard var moveComponent = owner.getComponent(MovementComponent.self) else {
            return
        }
        
        //print(moveComponent)
        
        let friendlyCities = world.allCities.filter { city in
            city.owningPlayerID == owner.owningPlayerID
        }
        
        let friendlyCityLocations = friendlyCities.map { city in
            city.position
        }
        
        let pathfindingResult = world.hexMap.rebuildPathFindingGraph(movementCosts: moveComponent.movementCosts, additionalEnterableTiles: friendlyCityLocations)
        moveComponent.pathfindingGraph = pathfindingResult.graph
        moveComponent.tileCoordToNodeMap = pathfindingResult.tileCoordToNodeMap
        
        guard let targetPosition = targetTile else {
            throw CommandErrors.missingTarget
        }
        
        guard let path = world.hexMap.findPathFrom(owner.position, to: targetPosition, pathfindingGraph: moveComponent.pathfindingGraph, tileCoordToNodeMap: moveComponent.tileCoordToNodeMap, movementCosts: moveComponent.movementCosts) else {
            print("No valid path from \(owner.position) to \(targetPosition).")
            return
        }
        
        print("Calculate path: \(path)")
        
        moveComponent.path = path
        
        owner.replaceComponent(component: moveComponent)
        owner = try moveComponent.move(in: world)
        world.replace(owner)
    }
    
    func canExecute(in world: World) -> Bool {
        if let owner = try? world.getUnitWithID(ownerID) {
            return owner.getComponent(MovementComponent.self) != nil
        }
        
        return false
    }
}
