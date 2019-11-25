//
//  CityController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 23/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftUI

final class CityController: ObservableObject {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double

    var citySpriteMap = [UUID: CitySprite]()
    var getColorForPlayerFunction: ((UUID) -> SKColor)?
    
    @Published var selectedCity: UUID?
    
    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
        
        City.onCityCreate = onCityCreate
    }

    func onCityCreate(city: City) {
        guard citySpriteMap[city.id] == nil else {
            print("A sprite for city already exists. Not creating a second one.")
            return
        }
        
        print("Creating sprite for city \(city)")
        // find a resource for the unit
        let color = getColorForPlayerFunction?(city.owningPlayer) ?? SKColor.white
        let sprite = CitySprite(city: city, playerColor: color)
        
        sprite.zPosition = 1
        
        // move sprite to correct position
        sprite.position = HexMapController.hexToPixel(city.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        citySpriteMap[city.id] = sprite
        
        scene.addChild(sprite)
    }
    
    func getCityForNode(_ node: SKSpriteNode) -> UUID? {
        for pair in citySpriteMap.enumerated() {
            if pair.element.value == node {
                return pair.element.key
            }
        }
        return nil
    }
    
    func deselectCity() {
        guard let cityID = selectedCity else {
            return
        }
        citySpriteMap[cityID]?.deselect()
    }
}
