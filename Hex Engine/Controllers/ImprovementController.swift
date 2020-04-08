//
//  ImprovementController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 08/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import Combine

final class ImprovementController: ObservableObject {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double

    var improvementSpriteMap = [AxialCoord: ImprovementSprite]()
    
    private var cancellables: Set<AnyCancellable>
    
    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.cancellables = Set<AnyCancellable>()
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
    }
    
    func subscribeToImprovementsIn(boxedWorld: WorldBox) {
        boxedWorld.$world.sink(receiveCompletion: { completion in
            print("Print CityController received completion \(completion) from world.cities")
        }, receiveValue: { [weak self] world in
            // there are three cases
            
            for improvement in world.improvements {
                
                // case 1: city is known to both CityController and World:
                if self?.improvementSpriteMap[improvement.key] != nil {
                    self?.updateImprovementSprite(improvement: improvement.value)
                }
            
                // case 2: city is known to world, but not yet to CityController
                if self?.improvementSpriteMap[improvement.key] == nil {
                    self?.createImprovementSprite(improvement: improvement.value)
                }
            }
            
            // case 3: the final case is where a city is known to the CityController, but not the world
            // i.e. when the city is destroyed
            for improvementCoord in (self?.improvementSpriteMap ?? [AxialCoord: ImprovementSprite]()).keys {
                if world.improvements[improvementCoord] == nil {
                    self?.removeImprovementSprite(at: improvementCoord)
                }
            }
            }).store(in: &cancellables)
    }

    func createImprovementSprite(improvement: TileImprovement) {
        guard improvementSpriteMap[improvement.position] == nil else {
            print("A sprite for improvement already exists. Not creating a second one.")
            return
        }
        
        print("Creating sprite for improvement \(improvement.title) at (\(improvement.position))")
        // find a resource for the unit
        let sprite = ImprovementSprite(improvement: improvement)
        
        // move sprite to correct position
        sprite.position = HexMapController.hexToPixel(improvement.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        improvementSpriteMap[improvement.position] = sprite
        
        scene.addChild(sprite)
    }
    
    func reset() {
        for sprite in improvementSpriteMap.values {
            sprite.removeAllChildren()
            sprite.removeFromParent()
        }
        
        improvementSpriteMap.removeAll()
        cancellables.removeAll()
    }
    
    func removeImprovementSprite(at coord: AxialCoord) {
        fatalError("Not implemented")
    }
    
    func updateImprovementSprite(improvement: TileImprovement) {
        return
    }
}
