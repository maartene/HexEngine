//
//  UnitController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

class UnitController {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double
    
    var unitSpriteMap = [Int: SKSpriteNode]()
    
    var selectedUnit: Int?
    
    var unitBecameSelected: ((Unit) -> Void)?
    var unitBecameDeselected: ((Int) -> Void)?
    
    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
        
        Unit.onUnitCreate = onUnitCreate
        Unit.onUnitChanged = onUnitChanged
    }
    
    func onUnitCreate(unit: Unit) {
        print("Creating sprite for unit \(unit)")
        // find a resource for the unit
        let sprite = SKSpriteNode(imageNamed: unit.name)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.25)
        
        sprite.zPosition = 1
        
        // move sprite to correct position
        sprite.position = HexMapController.hexToPixel(unit.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        
        
        unitSpriteMap[unit.id] = sprite
        scene.addChild(sprite)
    }
    
    
    
    func onUnitChanged(unit: Unit) {
        // find the sprite for the unit
        guard let sprite = unitSpriteMap[unit.id] else {
            print("No sprite for unit \(unit) found).")
            return
        }
        
        // for now, changes are the only thing we care about
        sprite.position = HexMapController.hexToPixel(unit.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
    }
    
    func getUnitForNode(_ node: SKSpriteNode) -> Int? {
        for pair in unitSpriteMap.enumerated() {
            if pair.element.value == node {
                return pair.element.key
            }
        }
        return nil
    }
    
    func selectUnit(_ unit: Unit) {
        deselectUnit()
        
        if let sprite = unitSpriteMap[unit.id] {
            let radius = max(sprite.size.width, sprite.size.height) / 2.0
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.strokeColor = SKColor.white
            circle.lineWidth = 2.0
            circle.glowWidth = 4.0
            sprite.addChild(circle)
        }
        
        selectedUnit = unit.id
        unitBecameSelected?(unit)
        
    }
    
    func deselectUnit() {
        if let selectedUnitID = selectedUnit {
            unitBecameDeselected?(selectedUnitID)
            if let previousSelectedUnit = unitSpriteMap[selectedUnitID] {
                previousSelectedUnit.removeAllChildren()
                selectedUnit = nil
            }
        }
    }
}
