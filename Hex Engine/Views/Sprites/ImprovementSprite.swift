//
//  ImprovementSprite.swift
//  Hex Engine
//
//  Created by Maarten Engels on 08/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

final class ImprovementSprite: SKSpriteNode {
    
    init(improvement: TileImprovement) {
        let texture = SKTexture(imageNamed: improvement.title)

        super.init(texture: texture, color: SKColor.white, size: texture.size())

        zPosition = SpriteZPositionConstants.IMPROVEMENT_Z
        //color = SKColor.white
        //colorBlendFactor = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
