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
    let movement: Double
    var remainingMovement: Double
    
    // patchfinding stuff
    var pathfindingGraph = GKGraph()                            // every entity with a movement component has its own pathfinding graph
    var nodeToTileCoordMap = [GKGraphNode: AxialCoord]()
    var tileCoordToNodeMap = [AxialCoord : GKGraphNode]()
    var path = [AxialCoord]()
    
    let possibleCommands: [Command]
    
    init(ownerID: UUID, movementCosts: [Tile: Double] = Tile.defaultCostsToEnter, movement: Double = 2) {
        self.ownerID = ownerID
        self.movementCosts = movementCosts
        self.movement = movement
        self.remainingMovement = movement
        
        self.possibleCommands = [MoveUnitCommand(ownerID: ownerID, targetTile: nil)]
    }
    
    func move(in world: World) throws -> Unit {
        var owner = try world.getUnitWithID(ownerID)
        var updatedComponent = self
        
        while updatedComponent.remainingMovement > 0 && updatedComponent.path.count > 0 {
            if updatedComponent.path.first! == owner.position {
                updatedComponent.path.remove(at: 0)
            }
            if updatedComponent.path.count > 0 {
                let nextStep = updatedComponent.path.removeFirst()
                let tile = world.hexMap[nextStep]
                if movementCosts[tile, default: -1] < 0 {
                    updatedComponent.remainingMovement = 0
                } else {
                    updatedComponent.remainingMovement -= updatedComponent.movementCosts[tile, default: 0]
                }
                owner.position = nextStep
            }
        }
        owner.replaceComponent(component: updatedComponent)
        Unit.onUnitChanged?(owner)
        return owner
    }
    
    func step(in world: World) {
        var updatedComponent = self
        updatedComponent.remainingMovement = movement
        if let updatedUnit = try? updatedComponent.move(in: world) {
            world.replace(updatedUnit)
        }
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
        
        print(moveComponent)
        
        world.hexMap.rebuildPathFindingGraph(movementCosts: moveComponent.movementCosts)
        
        guard let targetPosition = targetTile else {
            throw CommandErrors.missingTarget
        }
        
        guard let path = world.hexMap.findPathFrom(owner.position, to: targetPosition, movementCosts: moveComponent.movementCosts) else {
            print("No valid path from \(owner.position) to \(targetPosition).")
            return
        }
        
        print("Calculate path: \(path)")
        
        moveComponent.path = path
        
        owner.replaceComponent(component: moveComponent)
        owner = try moveComponent.move(in: world)
        world.replace(owner)
        //world.setPath(for: ownerID, path: path, moveImmediately: true)
    }
    
    /*
    func setPath(for unitID: UUID, path: [AxialCoord], moveImmediately: Bool = false) {
        guard var unit = units[unitID] else {
            print("unit with id \(unitID) not found.")
            return
        }
        
        //unit.path = path
        
        if moveImmediately {
        //    unit.move(hexMap: hexMap)
        }
        
        units[unit.id] = unit
        
        updateVisibilityForPlayer(player: currentPlayer!)
    }*/
    
    func canExecute(in world: World) -> Bool {
        if let owner = try? world.getUnitWithID(ownerID) {
            if let component = owner.getComponent(MovementComponent.self) {
            return component.movement > 0
            }
        }
        
        return false
    }
}
