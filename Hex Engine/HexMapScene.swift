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
    
    var onLoadedGameWorld: (() -> Void)?
    
    override func sceneDidLoad() {
        newGame()
    }
    
    func newGame() {
        if hexMapController != nil {
            hexMapController.reset()
        }
        
        let world = World(playerCount: 4, width: 84, height: 54, hexMapFactory: WorldFactory.CreateWorld)
        //let world = World(playerCount: 4, width: 42, height: 27, hexMapFactory: WorldFactory.CreateWorld)
        
        hexMapController = HexMapController(scene: self, world: world, tileWidth: 120.0, tileHeight: 140.0, tileYOffsetFactor: 0.74)
        
        // we assume that the player who saved the game was the current player.
        hexMapController.guiPlayer = world.currentPlayer!.id
        hexMapController.showMap()
        
        setupCamera()
        onLoadedGameWorld?()
    }
    
    func setupCamera() {
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
        
        return scenePointToNode(scenePoint)
    }
    
    func scenePointToNode(_ scenePoint: CGPoint) -> SKSpriteNode? {
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
    
    
    func load(url: URL? = nil) {
        print("HexMapScene:load")
        do {
            hexMapController.reset()
            let decoder = JSONDecoder()
            let data: Data
            if let url = url {
                data = try Data(contentsOf: url)
            } else {
                let url = URL(fileURLWithPath: "world.json")
                data = try Data(contentsOf: url)
            }
            
            let loadedWorld = try decoder.decode(World.self, from: data)
            
            hexMapController = HexMapController(scene: self, world: loadedWorld, tileWidth: 120.0, tileHeight: 140.0, tileYOffsetFactor: 0.74)
            
            // we assume that the player who saved the game was the current player.
            hexMapController.guiPlayer = loadedWorld.currentPlayer!.id
            hexMapController.showMap()
            
            setupCamera()
            
            // callback to signal parent that the game world was reloaded - maybe other scenes/view require updating?
            onLoadedGameWorld?()
            
            print("World loaded succesfully")
            } catch {
            print("An error of type '\(error)' occored.")
        }
    }
    
    override func keyDown(with event: NSEvent) {
        print(event.keyCode)
        let cameraMoveDistance = 20
        
        // 'Enter' key - next turn
        if event.keyCode == 36 {
            if hexMapController.guiPlayerIsCurrentPlayer {
                hexMapController.boxedWorld.nextTurn()
            }
        }
        // 'Right arrow' key
        if event.keyCode == 124 {
            if let camera = camera {
                camera.position = camera.position + CGPoint(x: cameraMoveDistance, y: 0)
            }
        }
        
        // 'Left arrow' key
        if event.keyCode == 123 {
            if let camera = camera {
                camera.position = camera.position + CGPoint(x: -cameraMoveDistance, y: 0)
            }
        }
        
        // 'Up arrow' key
        if event.keyCode == 126 {
            if let camera = camera {
                camera.position = camera.position + CGPoint(x: 0, y: cameraMoveDistance)
            }
        }
        
        // 'Down arrow' key
        if event.keyCode == 125 {
            if let camera = camera {
                camera.position = camera.position + CGPoint(x: 0, y: -cameraMoveDistance)
            }
        }
        
        // 'F' key
        if event.keyCode == 3 {
            if let camera = camera {
                camera.position = hexMapController.middleOfMapInWorldSpace()
            }
        }
    }
    
    
    // NOTE: we need to make sure this only gets called when currentPlayer is a guiplayer.
    // i.e. on players own turn.
    func save(url: URL? = nil) {
        guard hexMapController.guiPlayerIsCurrentPlayer else {
            print("Only save on own turn")
            return
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(hexMapController.boxedWorld.world)
            if let url = url {
                try data.write(to: url)
            } else {
                let url = URL(fileURLWithPath: "world.json")
                try data.write(to: url)
            }
            print("Succesfully saved world to: \(String(describing: url))")
        } catch {
            print("Error while saving: \(error)")
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        //print("mouseUp \(event)")
        
        let point = event.location(in: self)
        //let scenePoint = view!.convert(point, to: self)
        if let node = scenePointToNode(point) {
            hexMapController.clickedNode(node)
        }
    }
}
