//
//  HexMapController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

class HexMapController {

    let skScene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    
    init(skScene: SKScene, tileWidth: Double, tileHeight: Double) {
        self.skScene = skScene
        self.tileHeight = tileHeight
        self.tileWidth = tileWidth
    }

    func axialCoordToPixel(_ hex: AxialCoord) -> CGPoint {
        var x = tileWidth * (sqrt(3.0) * Double(hex.q))
        var y = tileHeight * 3.0 / 2 * hex.r
        return CGPoint(x: x, y: y)
    }
    
    func showMap(map: HexMap) {
        for y in 0 ..< map.height {
            let yIndex = map.height - y
            for x in 0 ..< map.width {
                let tile = SKSpriteNode(imageNamed: "grass_01")
                let yPos = Double(yIndex) * 0.70 * tileHeight
                let xPos = Double(x)  + 0.5 * Double(yIndex % 2)
                tile.position = CGPoint(x: xPos * tileWidth, y: yPos)
                
                // add x/y/z coordinates to tile as text
                let label = SKLabelNode(text: "\(x),\(y)")
                tile.addChild(label)
                skScene.addChild(tile)
                
            }
        }
    }
    
    func middleOfMapInWorldSpace(map: HexMap) -> CGPoint {
        let x = Double(map.width) * tileWidth * 0.5
        let y = Double(map.height) * tileHeight * 0.5
        return CGPoint(x: x, y: y)
    }
    
}
