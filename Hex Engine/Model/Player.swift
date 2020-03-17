//
//  Player.swift
//  Hex Engine
//
//  Created by Maarten Engels on 15/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct Player: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    
    var ai: AI?
    
    var visibilityMap = [AxialCoord: TileVisibility]()
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func processTurn(in world: World) {
        
    }
    
    func calculateVisibility(in world: World) -> Player {
        var player = self
        var newVisibilityMap = self.visibilityMap
        for coord in world.hexMap.getTileCoordinates() {
            if visibilityMap[coord] ?? .unvisited == .visited || visibilityMap[coord] ?? .unvisited == .visible {
                newVisibilityMap[coord] = .visited
            }
        }
        
        for unit in world.units.values.filter({$0.owningPlayerID == self.id }) {
            newVisibilityMap[unit.position] = .visible
            let visibleNeighbours = HexMap.coordinatesWithinRange(from: unit.position, range: unit.visibility)
            for neighbour in visibleNeighbours {
                newVisibilityMap[neighbour] = .visible
            }
        }
        
        for city in world.cities.values.filter({$0.owningPlayer == self.id }) {
            newVisibilityMap[city.position] = .visible
            let visibleNeighbours = HexMap.coordinatesWithinRange(from: city.position, range: city.visibility)
            for neighbour in visibleNeighbours {
                newVisibilityMap[neighbour] = .visible
            }
        }
        
        //onVisibilityMapUpdated?()
        player.visibilityMap = newVisibilityMap
        return player
    }
}

enum TileVisibility {
    case unvisited
    case visited
    case visible
}
