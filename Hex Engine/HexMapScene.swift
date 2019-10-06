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
        
        camera?.setScale(cameraScale)
    }
    
    override func scrollWheel(with event: NSEvent) {
        print("scrollwheel")
        setZoom(delta: event.scrollingDeltaY * 0.1)
    }
}
