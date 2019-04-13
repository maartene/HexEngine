//
//  GameScene.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var dragPositionStart:CGPoint?
    var dragPositionTarget:CGPoint?
    var cameraScale: CGFloat = 1.0
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        /*
         // Get label node from scene and store it for use later
         self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
         if let label = self.label {
         label.alpha = 0.0
         label.run(SKAction.fadeIn(withDuration: 2.0))
         }
         
         
         // Create shape node to use during mouse interaction
         let w = (self.size.width + self.size.height) * 0.05
         self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
         
         if let spinnyNode = self.spinnyNode {
         spinnyNode.lineWidth = 2.5
         
         spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
         spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
         SKAction.fadeOut(withDuration: 0.5),
         SKAction.removeFromParent()]))
         }*/
        
        let map = HexMap(width: 30, height: 20)
        
        let hmc = HexMapController(skScene: self, tileWidth: 120.0, tileHeight: 140.0)
        hmc.showMap(map: map)
        
        let camera = SKCameraNode()
        self.addChild(camera)
        self.camera = camera
        self.camera?.position = hmc.middleOfMapInWorldSpace(map: map)
        self.camera?.zPosition = 5
        self.camera?.setScale(cameraScale)
        
    }
    
    // drag map around
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        dragPositionStart = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        dragPositionTarget = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        dragPositionTarget = nil
        dragPositionStart = nil
    }
    
    func setZoom(delta zoomDelta: CGFloat) {
        var newZoom = (self.camera?.xScale ?? 1) + zoomDelta
        if newZoom < 1 {
            newZoom = 1
        } else if newZoom > 4 {
            newZoom = 4
        }
        cameraScale = newZoom
        //print("cameraScale: \(cameraScale)")
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func scrollWheel(with event: NSEvent) {
        //print("scrollWheel \(event.scrollingDeltaY * 0.1)")
        self.setZoom(delta: event.scrollingDeltaY * 0.1)
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let dragStart = dragPositionStart, let dragTarget = dragPositionTarget {
            let movement = dragStart - dragTarget
            
            let currentPosition = camera?.position ?? CGPoint.zero
            camera?.position = currentPosition + movement
            
            // Initialize _lastUpdateTime if it has not already been
            if (self.lastUpdateTime == 0) {
                self.lastUpdateTime = currentTime
            }
        }
        
        camera?.setScale(cameraScale)
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
