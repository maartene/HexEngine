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
    
    //var unitBecameSelected: ((Unit) -> Void)?
    //var unitBecameDeselected: ((UUID) -> Void)?
    var getColorForPlayerFunction: ((UUID) -> SKColor)?
    
    private var cancellables: Set<AnyCancellable>
    
    var pathIndicator: SKShapeNode? {
        didSet {
            if pathIndicator == nil, let oldValue = oldValue {
                scene.removeChildren(in: [oldValue])
            }
        }
    }
    
    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.cancellables = Set<AnyCancellable>()
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
    }
    
    func subscribeToUnitsIn(world: World) {
        world.$units.sink(receiveCompletion: { completion in
            print("Print UnitController received completion \(completion) from world.units")
        }, receiveValue: { [weak self] units in
            // there are three cases
            
            for unitID in units.keys {
                
                // case 1: unit is known to both UnitController and World:
                if self?.unitSpriteMap[unitID] != nil, let unit = units[unitID]{
                    self?.updateUnitSprite(unit: unit)
                }
            
                // case 2: unit is known to world, but not yet to UnitController
                if self?.unitSpriteMap[unitID] == nil, let unit = units[unitID] {
                    self?.createUnitSprite(unit: unit)
                }
            }
            
            // case 3: the final case is where a unit is known to the UnitController, but not the world
            // i.e. when the unit is removed
            for unitID in (self?.unitSpriteMap ?? [UUID: UnitSprite]()).keys {
                if units[unitID] == nil {
                    self?.removeUnitSprite(unitID: unitID)
                }
            }
            }).store(in: &cancellables)
    }
    
    func createUnitSprite(unit: Unit) {
        print("Creating sprite for unit \(unit.name) (\(unit.id))")
        // find a resource for the unit
        let color = getColorForPlayerFunction?(unit.owningPlayerID) ?? SKColor.white
        
        let sprite = UnitSprite(unit: unit, playerColor: color)
        
        sprite.zPosition = 1
          
        // move sprite to correct position
        sprite.position = HexMapController.hexToPixel(unit.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        unitSpriteMap[unit.id] = sprite
        
        scene.addChild(sprite)
    }
    
    
    
    func updateUnitSprite(unit: Unit) {
        // find the sprite for the unit
        guard let sprite = unitSpriteMap[unit.id] else {
            print("No sprite for unit \(unit) found).")
            return
        }
        
        // for now, changes are the only thing we care about
        sprite.position = HexMapController.hexToPixel(unit.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        // check whether the sprite is dead
        if let hc = unit.getComponent(HealthComponent.self) {
            if hc.isDead {
                removeUnitSprite(unitID: unit.id)
            }
        }
    }
    
    func removeUnitSprite(unitID: UUID) {
        // find the sprite for the unit
        if let sprite = unitSpriteMap.removeValue(forKey: unitID) {
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
        //unitBecameSelected?(unit)
        
    }
    
    func deselectUnit(uiState: UI_State = .map) {
        pathIndicator = nil
        
        if let selectedUnitID = selectedUnit {
            //unitBecameDeselected?(selectedUnitID)
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
        }
        unitSpriteMap.removeAll()
        cancellables.removeAll()
    }
        
}
