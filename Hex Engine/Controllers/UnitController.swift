//
//  UnitController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

protocol UnitDelegate {
    mutating func onUnitCreate(unit: Unit)
    mutating func onUnitChanged(unit: Unit)
}

struct UnitController: UnitDelegate {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double
    
    var unitSpriteMap = [Int: SKSpriteNode]()
    
    var selectedUnit: Int?
    
    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
    }
    
    mutating func onUnitCreate(unit: Unit) {
        // find a resource for the unit
        let sprite = SKSpriteNode(imageNamed: unit.name)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.25)
        
        // move sprite to correct position
        sprite.position = HexMapController.hexToPixel(unit.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        unitSpriteMap[unit.id] = sprite
        scene.addChild(sprite)
    }
    
    mutating func onUnitChanged(unit: Unit) {
        // find the sprite for the unit
        guard let sprite = unitSpriteMap[unit.id] else {
            print("No sprite for unit \(unit) found).")
            return
        }
        
        // for now, changes are the only thing we care about
        sprite.position = HexMapController.hexToPixel(unit.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
    }
}
