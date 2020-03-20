//
//  UnitController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import Combine

final class UnitController: ObservableObject {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double
    
    var unitSpriteMap = [UUID: UnitSprite]()
    
    @Published var selectedUnit: UUID?
    
    var unitBecameSelected: ((Unit) -> Void)?
    var unitBecameDeselected: ((UUID) -> Void)?
    var getColorForPlayerFunction: ((UUID) -> SKColor)?
    
    var pathIndicator: SKShapeNode? {
        didSet {
            if pathIndicator == nil, let oldValue = oldValue {
                scene.removeChildren(in: [oldValue])
            }
        }
    }
    
    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
        
        Unit.onUnitCreate = onUnitCreate
        Unit.onUnitChanged = onUnitChanged
        Unit.onUnitDies = onUnitRemoved
    }
    
    func onUnitCreate(unit: Unit) {
        print("Creating sprite for unit \(unit)")
        // find a resource for the unit
        let color = getColorForPlayerFunction?(unit.owningPlayerID) ?? SKColor.white
        
        let sprite = UnitSprite(unit: unit, playerColor: color)
        
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
    
    func onUnitRemoved(unit: Unit) {
        // find the sprite for the unit
        if let sprite = unitSpriteMap.removeValue(forKey: unit.id) {
            scene.removeChildren(in: [sprite])
        }
    }
    
    func getUnitForNode(_ node: UnitSprite) -> UUID? {
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
            sprite.select()
            if unit.getComponent(MovementComponent.self)?.path.count ?? 0 > 0 {
                drawPath(for: unit)
            } else {
                pathIndicator = nil
            }
        }
        
        selectedUnit = unit.id
        unitBecameSelected?(unit)
        
    }
    
    func deselectUnit(uiState: UI_State = .map) {
        pathIndicator = nil
        
        if let selectedUnitID = selectedUnit {
            unitBecameDeselected?(selectedUnitID)
            if let previousSelectedUnit = unitSpriteMap[selectedUnitID] {
                previousSelectedUnit.deselect()
                if uiState == .map { selectedUnit = nil }
            }
        }
    }
    
    func drawPath(for unit: Unit) {
        guard let moveComponent = unit.getComponent(MovementComponent.self) else {
            return
        }
        
        var points = [HexMapController.hexToPixel(unit.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)]
        let pointsToAdd = moveComponent.path.map { coord in
            HexMapController.hexToPixel(coord, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        }
        points.append(contentsOf: pointsToAdd)
        
        pathIndicator = SKShapeNode(points: &points, count: points.count)
        pathIndicator?.lineWidth = 4.0
        pathIndicator?.zPosition = 1
        pathIndicator?.strokeColor = SKColor.blue
        scene.addChild(pathIndicator!)
    }
    
    func showHideUnits(in world: World, visibilityMap: [AxialCoord: TileVisibility]) {
        for unitID in unitSpriteMap.keys {
            if let unit = try? world.getUnitWithID(unitID) {
                if visibilityMap[unit.position] ?? .unvisited == .visible {
                    unitSpriteMap[unitID]!.alpha = 1
                } else {
                    unitSpriteMap[unitID]!.alpha = 0
                }
            }
        }
    }
    
    func reset() {
        for unitSprite in unitSpriteMap.values {
            unitSprite.removeAllChildren()
            unitSprite.removeFromParent()
        }
        
        unitSpriteMap.removeAll()
    }
        
}
