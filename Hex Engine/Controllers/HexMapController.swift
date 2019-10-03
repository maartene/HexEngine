//
//  HexMapController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

protocol HexMapSceneDelegate {
    
}

struct HexMapController {
    
    let world: World

    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double
    
    var tileSKSpriteNodeMap = [AxialCoord: SKSpriteNode]()
    
    var selectedTiles = [SKSpriteNode]()
    
    var unitController: UnitController
    
    init(scene: SKScene, world: World, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.scene = scene
        self.world = world
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
        unitController = UnitController(with: scene, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
    }
    
    static func hexToPixel(_ hex: AxialCoord, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) -> CGPoint {
        //let x = tileWidth * (sqrt(2.0) * Double(hex.q) + sqrt(2)/2.0 * Double(hex.r))
        //let y = tileHeight * (3.0 / 2 * Double(hex.r))
        let x = tileWidth * (0.5 * Double(hex.r) + Double(hex.q))
        let y = tileHeight * Double(hex.r) * tileYOffsetFactor
        return CGPoint(x: x, y: y)
    }
    
    func hexToPixel(_ hex: AxialCoord) -> CGPoint {
        return Self.hexToPixel(hex, tileWidth: self.tileWidth, tileHeight: self.tileHeight, tileYOffsetFactor: self.tileYOffsetFactor)
    }
    
    /*func pixelToHex(_ point: CGPoint) -> AxialCoord {
        //let x = tileWidth * (sqrt(2.0) * Double(hex.q) + sqrt(2)/2.0 * Double(hex.r))
        //let y = tileHeight * (3.0 / 2 * Double(hex.r))
        //let x = tileWidth * (0.5 * Double(hex.r) + Double(hex.q))
        //let y = tileHeight * Double(hex.r) * 0.75
        let q = (2 * Double(point.y) - Double(point.x)) / tileWidth
        let r = Double(point.y) / tileHeight / 0.75
        let s = -q - r
        
        let cubeCoord = CubeCoord.roundToCubeCoord(fractX: q, fractY: s, fractZ: r)
        
        return cubeCoord.toAxial()
    }*/
    
    mutating func showMap() {
        for coord in world.hexMap.getTileCoordinates() {
            let q = coord.q
            let r = coord.r
            
            if world.hexMap[q,r] != .void {
                let spriteName: String
                switch world.hexMap[q,r] {
                case .Forest:
                    spriteName = "grass_13"
                case .Grass:
                    spriteName = "grass_05"
                case .Mountain:
                    spriteName = "dirt_18"
                case .Sand:
                    spriteName = "sand_07"
                case .Water:
                    spriteName = "water"
                default:
                    spriteName = ""
                }
                let tile = SKSpriteNode(imageNamed: spriteName)
                
                //tile.anchorPoint = CGPoint(x: tileWidth / 2, y: tileHeight / 2)
                let pos = hexToPixel(AxialCoord(q: q, r: r))
                tile.userData = ["q": q, "r": r]
                tile.position = pos
                tile.color = SKColor.white
                tile.colorBlendFactor = 1.0
                
                // add x/y/z coordinates to tile as text
                /*
                let label = SKLabelNode(text: "\(q),\(r)")
                label.zPosition = tile.zPosition + 1
                tile.addChild(label)
                 */
                
                tileSKSpriteNodeMap[AxialCoord(q: q, r: r)] = tile
                
                scene.addChild(tile)
            }
        }
    }
    
    func middleOfMapInWorldSpace() -> CGPoint {
        return hexToPixel(AxialCoord(q: 0, r: 0))
    }
    
    func clickedNode(_ node: SKSpriteNode) {
        // first, determine what kind of node this is.
        // is it a unit?
        if unitController.unitSpriteMap.values.contains(node) {
            
            print("Clicked unit node: node")
            node.color = SKColor.blue
        } else if tileSKSpriteNodeMap.values.contains(node) {
            if let q = node.userData?["q"] as? Int, let r = node.userData?["r"] as? Int {
                print("Clicked tile at coord \(q), \(r)", node)
                // highlight tile
                node.color = SKColor.red
            }
        }
        
        
        
    }
    
    func clickAtPosition(pos: CGPoint, map: HexMap) {
        let node: SKNode?
        if scene.nodes(at: pos).count > 1 {
            var distance = Double.infinity
            var closestNode: SKNode?
            for tryNode in scene.nodes(at: pos) {
                let xDistance = tryNode.position.x - pos.x
                let yDistance = tryNode.position.y - pos.y
                let tryDistance = Double(xDistance * xDistance + yDistance * yDistance)
                if tryDistance < distance {
                    distance = tryDistance
                    closestNode = tryNode
                }
            }
            node = closestNode
        } else {
            node = scene.nodes(at: pos).first
        }
    }
}
