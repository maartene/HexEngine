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
        var hexMap = HexMap(width: width, height: height)
        
        let perlinSource = GKPerlinNoiseSource(frequency: 2, octaveCount: 3, persistence: 0.5, lacunarity: 1.75, seed: 123)
        
        let perlinNoise = GKNoise(perlinSource)
        
        let perlinMap = GKNoiseMap(perlinNoise, size: [Double(width), Double(height)] , origin: [0.0, 0.0], sampleCount: [Int32(width), Int32(height)], seamless: true)
        
        return hexMap
    }
    
    
}
