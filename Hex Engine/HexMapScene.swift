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
    
    override func sceneDidLoad() {
        
        //self.lastUpdateTime = 0
        
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
    
    override func didMove(to view: SKView) {
        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(panHandler))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(clickHandler))
        view.addGestureRecognizer(clickGestureRecognizer)
    }
    
    // drag map around
    @objc
    func panHandler(_ gestureRecognize: NSPanGestureRecognizer) {
        guard let view = self.view else {
            return
        }
        
        // get the position within the view where the gesture event happened.
        let p = gestureRecognize.location(in: view)
        
        // convert the position within the view to position within the scene
        let scenePoint = view.convert(p, to: self)
        
        switch gestureRecognize.state {
        case .began:
            dragPositionStart = scenePoint
        case .changed:
            dragPositionTarget = scenePoint
        case .ended:
            // make the block dynamic again, so it's affected by gravity and other forces.
            dragPositionTarget = nil
            dragPositionStart = nil
        default:
            print("unknown state: \(gestureRecognize.state)")
        }
    }
    
    @objc
    func clickHandler(_ gestureRecognize: NSClickGestureRecognizer) {
        guard let view = self.view else {
            return
        }
        
        // * let's see what was clicked *
        let p = gestureRecognize.location(in: view)
        
        let scenePoint = view.convert(p, to: self)
        
        let node: SKNode?
        if self.nodes(at: scenePoint).count > 1 {
            var distance = Double.infinity
            var closestNode: SKNode?
            for tryNode in self.nodes(at: scenePoint) {
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
            node = self.nodes(at: scenePoint).first
        }
        
        if let node = node as? SKSpriteNode {
            hexMapController.clickedNode(node)
        }
    }
    
    func setZoom(delta zoomDelta: CGFloat) {
        var newZoom = (self.camera?.xScale ?? 1) + zoomDelta
        if newZoom < 1 {
            newZoom = 1
        } else if newZoom > HexMapScene.MAX_ZOOM {
            newZoom = HexMapScene.MAX_ZOOM
        }
        cameraScale = newZoom
        //print("cameraScale: \(cameraScale)")
    }
    
    override func scrollWheel(with event: NSEvent) {
        //print("scrollWheel \(event.scrollingDeltaY * 0.1)")
        self.setZoom(delta: event.scrollingDeltaY * 0.1)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let dragStart = dragPositionStart, let dragTarget = dragPositionTarget {
            let movement = dragStart - dragTarget
            
            let currentPosition = camera?.position ?? CGPoint.zero
            camera?.position = currentPosition + movement
            
            // Initialize _lastUpdateTime if it has not already been
//            if (self.lastUpdateTime == 0) {
//                self.lastUpdateTime = currentTime
//            }
        }
        
        camera?.setScale(cameraScale)
        
        /*// Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        } */
        
//        self.lastUpdateTime = currentTime
    }
}
