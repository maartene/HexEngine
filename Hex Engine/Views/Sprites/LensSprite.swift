//
//  LensSprite.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SpriteKit

final class LensSprite: SKSpriteNode {
    let hexPosition: AxialCoord
    
    init(hexPosition: AxialCoord) {
        self.hexPosition = hexPosition
        let texture = SKTexture(imageNamed: "LensForHex")
        
        super.init(texture: texture, color: SKColor.white, size: texture.size())
        
        zPosition = SpriteZPositionConstants.LENS_Z
        color = SKColor.white
        colorBlendFactor = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tintSprite(color: SKColor) {
        self.color = color
    }
    
    func resetSpriteTint() {
        self.color = SKColor.white
    }
}
