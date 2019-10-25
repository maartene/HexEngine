//
//  CityController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 23/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

final class CityController {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double

    var citySpriteMap = [UUID: SKSpriteNode]()

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
        let sprite = SKSpriteNode(imageNamed: "windmill_complete")
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.25)
        
        sprite.zPosition = 1
        
        // move sprite to correct position
        sprite.position = HexMapController.hexToPixel(city.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        
        
        citySpriteMap[city.id] = sprite
        
        let cityLabel = LabelPanel(text: city.name)
        cityLabel.position = -sprite.midPointOfFrame - cityLabel.midPointOfFrame
        //let cityLabelFrame = cityLabel.calculateAccumulatedFrame()
        //cityLabel.position = CGPoint(x: -cityLabelFrame.width / 2.0, y: -sprite.size.height / 2.0 - cityLabelFrame.height / 2.0)
        sprite.addChild(cityLabel)
        scene.addChild(sprite)
    }
}
