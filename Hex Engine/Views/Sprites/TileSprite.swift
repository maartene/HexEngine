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
        result[.Forest] = SKTexture(imageNamed: "Forest")
        result[.Grass] = SKTexture(imageNamed: "Grass")
        result[.Mountain] = SKTexture(imageNamed: "dirt_18")
        result[.Sand] = SKTexture(imageNamed: "sand_07")
        result[.Water] = SKTexture(imageNamed: "water")
        result[.Hill] = SKTexture(imageNamed: "Hill")
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
                    zPosition = 100
                case .visited:
                    texture = visibleTexture
                    color = SKColor.gray
                    zPosition = 0
                    //alpha = 0.25
                case .visible:
                    texture = visibleTexture
                    zPosition = 0
                    color = SKColor.white
                }
            }
        }
    }
    
    init(tile: Tile, hexPosition: AxialCoord) {
        self.hexPosition = hexPosition
        
        hiddenTexture = SKTexture(imageNamed: "Unknown")
        visibleTexture = TileSprite.tileTextureMap[tile] ?? SKTexture()
                
        super.init(texture: hiddenTexture, color: SKColor.white, size: hiddenTexture.size())
        zPosition = 100
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
    
    func tintSprite(color: SKColor) {
        self.color = color
    }
    
    func resetSpriteTint() {
        self.color = SKColor.white
    }
    
    deinit {
        // print("Removing tilesprite: \(self)")
    }
}
