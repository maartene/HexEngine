//
//  CitySprite.swift
//  Hex Engine
//
//  Created by Maarten Engels on 24/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SpriteKit

class CitySprite: SKSpriteNode {
        var playerBadge: SKSpriteNode
        var selectionIndicator: SKShapeNode
        var cityNameLabel: SKLabelNode
        
        
        init(city: City, playerColor: SKColor = SKColor.white) {
            let texture = SKTexture(imageNamed: "windmill")
            
            // add "selection indicator"
            let radius = max(texture.size().width, texture.size().height) / 2.0
            selectionIndicator = SKShapeNode(circleOfRadius: radius)
            selectionIndicator.strokeColor = SKColor.white
            selectionIndicator.lineWidth = 2.0
            selectionIndicator.glowWidth = 4.0
            
            // add "player badge"
            playerBadge = SKSpriteNode(imageNamed: "badge")
            playerBadge.zPosition = 0.1
            playerBadge.anchorPoint = CGPoint(x: 0, y: 1)
            playerBadge.colorBlendFactor = 1.0
            playerBadge.color = playerColor
            
            // add "city label"
            cityNameLabel = SKLabelNode(text: city.name)
            cityNameLabel.fontName = "American Typewriter"
            cityNameLabel.fontSize = 16
            
            super.init(texture: texture, color: SKColor.white, size: texture.size())
            
            anchorPoint = CGPoint(x: 0.5, y: 0.25)
            cityNameLabel.position = cityNameLabel.position - CGPoint(x: 0, y: midPointOfFrame.y + cityNameLabel.midPointOfFrame.y)
            
            addChild(playerBadge)
            addChild(selectionIndicator)
            addChild(cityNameLabel)
            
            deselect()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func select() {
            selectionIndicator.isHidden = false
        }
        
        func deselect() {
            selectionIndicator.isHidden = true
        }
        
    deinit {
        print("Deallocating city: \(self)")
    }
    
    }
