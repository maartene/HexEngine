//
//  HexMap.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

class HexMap {
    let width: Int
    let height: Int
    
    
    let tileWidth = 120.0
    let tileHeight = 140.0
    
    let tiles: [Int]
    
    init(width: Int, height: Int) {
        self.width = width;
        self.height = height;
        
        tiles = [Int].init(repeating: 0, count: width * height)
    }
    
    func showMap(skScene: SKScene) {
        
        
        for y in 0 ..< height {
            let yIndex = height - y
            for x in 0 ..< width {
                let tile = SKSpriteNode(imageNamed: "grass_01")
                let yPos = Double(yIndex) * 0.70 * tileHeight
                let xPos = Double(x)  + 0.5 * Double(yIndex % 2)
                tile.position = CGPoint(x: xPos * tileWidth, y: yPos)
                skScene.addChild(tile)
            }
        }
    }
    
    func middleOfMapInWorldSpace() -> CGPoint {
        let x = Double(width) * tileWidth * 0.5
        let y = Double(height) * tileHeight * 0.5
        return CGPoint(x: x, y: y)
    }
}
