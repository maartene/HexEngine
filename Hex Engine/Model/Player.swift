//
//  Player.swift
//  Hex Engine
//
//  Created by Maarten Engels on 15/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

struct Player: Identifiable {
    let id = UUID()
    
    var visibilityMap = [AxialCoord: TileVisibility]()
}

enum TileVisibility {
    case unvisited
    case visited
    case visible
}
