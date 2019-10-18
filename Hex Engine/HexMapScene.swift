//
//  GameScene.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit

class HexMapScene: SKScene {
    
    static let MAX_ZOOM: CGFloat = 8.0
    
    var dragPositionStart:CGPoint?
    var dragPositionTarget:CGPoint?
    var cameraScale: CGFloat = 1.0
    
    var hexMapController: HexMapController!
    var uiState = UI_State.map
    
    override func sceneDidLoad() {
        let world = World(width: 84, height: 54, hexMapFactory: WorldFactory.CreateWorld)
    
        hexMapController = HexMapController(scene: self, world: world, tileWidth: 120.0, tileHeight: 140.0, tileYOffsetFactor: 0.74)
        
        hexMapController.showMap()
        
        let camera = SKCameraNode()
        self.addChild(camera)
        self.camera = camera
        self.camera?.position = hexMapController.middleOfMapInWorldSpace()
        self.camera?.zPosition = 5
        self.camera?.setScale(cameraScale)
    }
    
    func screenPointToNode(_ point: CGPoint) -> SKSpriteNode? {
        guard let view = view else {
            return nil
        }
        
        let scenePoint = view.convert(point, to: self)
        
        let nodesToCheck = nodes(at: scenePoint).compactMap { node in
            node as? SKSpriteNode
        }
        
        let node: SKSpriteNode?
        if nodesToCheck.count > 1 {
            var distance = Double.infinity
            var closestNode: SKSpriteNode?
            for tryNode in nodesToCheck {
                let xDistance = tryNode.position.x - scenePoint.x
                let yDistance = tryNode.position.y - scenePoint.y
                let tryDistance = Double(xDistance * xDistance + yDistance * yDistance)
                if tryDistance < distance {
                    distance = tryDistance
                    closestNode = tryNode
                }
            }
            node = closestNode
        } else {
            node = nodesToCheck.first
        }
        
        return node
    }
    
    func setZoom(delta zoomDelta: CGFloat) {
        var newZoom = (self.camera?.xScale ?? 1) + zoomDelta
        if newZoom < 1 {
            newZoom = 1
        } else if newZoom > HexMapScene.MAX_ZOOM {
            newZoom = HexMapScene.MAX_ZOOM
        }
        cameraScale = newZoom
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let dragStart = dragPositionStart, let dragTarget = dragPositionTarget {
            let movement = dragStart - dragTarget
            
            let currentPosition = camera?.position ?? CGPoint.zero
            camera?.position = currentPosition + movement
        }
        
        // Allow the hexMapController to provide information based on the mouse location.
        // Note: NSEvent.mouseLocation is in screen coordinates, as in *the entire screen*. By substracting the location of the game window (if it exists) we get the actual screen coordinates within the view (gesture recognizers perform this transformation automatically, so it is not necessary there.
        let mousePosition = NSEvent.mouseLocation - (view?.window?.frame.origin ?? CGPoint.zero)
        if let node = screenPointToNode(mousePosition) {
            //print("mouse over node: \(node)")
            hexMapController.mouseOverNode(node)
        }
        
        camera?.setScale(cameraScale)
    }
}
