//
//  TileSprite.swift
//  Hex Engine
//
//  Created by Maarten Engels on 24/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SpriteKit




class TileSprite: SKSpriteNode {
    static private var tileTextureMap: [Tile: SKTexture] = {
        var result = [Tile: SKTexture]()
        result[.Forest] = SKTexture(imageNamed: "grass_13")
        result[.Grass] = SKTexture(imageNamed: "grass_05")
        result[.Mountain] = SKTexture(imageNamed: "dirt_18")
        result[.Sand] = SKTexture(imageNamed: "sand_07")
        result[.Water] = SKTexture(imageNamed: "water")
        return result
    }()
    
    // I'm sharing the selectionIndicator between all instances of TileSprites, because otherwise the number of nodes doubles, for no reason at all.
    static private var selectionIndicator: SKShapeNode = {
        let size = TileSprite.tileTextureMap[.Water]?.size() ?? CGSize(width: 64, height: 48)
        let radius = max(size.width, size.height) / 2.0
        let sprite = SKShapeNode(circleOfRadius: radius)
        sprite.strokeColor = SKColor.white
        sprite.lineWidth = 2.0
        sprite.glowWidth = 4.0
        return sprite
    }()
    
    let hexPosition: AxialCoord
    var hiddenTexture: SKTexture
    var visibleTexture: SKTexture
    
    var visibility: TileVisibility = .unvisited {
        didSet {
            if oldValue != visibility {
                switch visibility {
                case .unvisited:
                    texture = hiddenTexture
                case .visited:
                    texture = visibleTexture
                    alpha = 0.25
                case .visible:
                    texture = visibleTexture
                    alpha = 1
                }
            }
        }
    }
    
    init(tile: Tile, hexPosition: AxialCoord) {
        self.hexPosition = hexPosition
        
        hiddenTexture = SKTexture(imageNamed: "unknown")
        visibleTexture = TileSprite.tileTextureMap[tile] ?? SKTexture()
                
        super.init(texture: hiddenTexture, color: SKColor.white, size: hiddenTexture.size())
        
        color = SKColor.white
        colorBlendFactor = 1.0

        deselect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select() {
        TileSprite.selectionIndicator.position = self.position
    }
    
    func deselect() {
        //selectionIndicator.isHidden = true
    }
}
