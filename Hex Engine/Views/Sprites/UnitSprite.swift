//
//  UnitSprite.swift
//  Hex Engine
//
//  Created by Maarten Engels on 24/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SpriteKit

class UnitSprite: SKSpriteNode {
    var playerBadge: SKSpriteNode
    var selectionIndicator: SKShapeNode
    
    
    
    
    init(unit: Unit, playerColor: SKColor = SKColor.white) {
        print("Looking for texture for \(unit.name)")
        let texture = SKTexture(imageNamed: unit.name)
                
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
        
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        
        anchorPoint = CGPoint(x: 0.5, y: 0.25)
        
        
        addChild(playerBadge)
        addChild(selectionIndicator)
        
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
        print("Deallocating unit: \(self)")
    }
}
