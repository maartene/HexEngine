//
//  TileInfoLabel.swift
//  Hex Engine
//
//  Created by Maarten Engels on 27/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SwiftUI

struct TileInfoLabel: View {
    @ObservedObject var hexMapController: HexMapController
    
    
    var selectedTile: Tile {
        if let coord = hexMapController.selectedTile {
            return hexMapController.boxedWorld.world.hexMap[coord]
        } else {
            return .void
        }
    }
    
    var body: some View {
        VStack {
            if selectedTile == .void {
            } else {
                ZStack {
                    Text("TILE").font(Font.custom("American Typewriter", size: 64)).opacity(0.5)
                    Text("""
                        Tile: \(hexMapController.selectedTile?.description ?? "not a tile")
                        \(selectedTile.stringValue)
                        Movement cost: \(Tile.defaultCostsToEnter[selectedTile, default: -1] < 0 ? "Impassible" : String(Tile.defaultCostsToEnter[selectedTile, default: -1]))
                        Yield: \(tileYield)
                    """)
                    .padding() .background(Color.gray.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
                }
            }
        }
    }
    
    var tileYield: String {
        if let coord = hexMapController.selectedTile {
            return hexMapController.boxedWorld.world.getTileYield(for: coord).description
        }
        return "unknown"
    }
}
