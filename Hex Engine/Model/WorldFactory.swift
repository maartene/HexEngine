//
//  WorldFactory.swift
//  Hex Engine
//
//  Created by Maarten Engels on 13/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import GameplayKit

struct WorldFactory {
    
    static func CreateWorld(width: Int, height: Int) -> HexMap {
        let hexMap = HexMap(width: width, height: height)
        
        let perlinSource = GKPerlinNoiseSource(frequency: 0.2, octaveCount: 5, persistence: 0.7, lacunarity: 1.75, seed: 123)
        
        let perlinNoise = GKNoise(perlinSource)
        
        let halfR = height / 2
        let halfQ = (width / 2)
        
        let perlinMap = GKNoiseMap(perlinNoise, size: [Double(width+1), Double(height+1)] , origin: [0.0, 0.0], sampleCount: [Int32(width+1), Int32(height+1)], seamless: true)
        
        for r in -halfR ... halfR {
            
            for q in (-halfQ - (Double(r) / 2.0).roundToZero()) ... (halfQ - (Double(r) / 2.0).roundToZero()) {
                
                let value = (perlinMap.value(at: [Int32(q + halfQ), Int32(r + halfR)]) + 1.0) / 2.0
                // print(value)
                let tile: Tile
                switch value {
                case 0 ..< 0.4:
                    tile = .Water
                case 0.4 ..< 0.5:
                    tile = .Sand
                case 0.5 ..< 0.7:
                    tile = .Grass
                case 0.7 ..< 0.9:
                    tile = .Forest
                case 0.9 ... 1.0:
                    tile = .Mountain
                default:
                    tile = .void
                }
                hexMap[q,r] = tile
            }
        }
        
        
        
        return hexMap
    }
}
