//
//  ViewController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit
import SwiftUI

class ViewController: NSViewController {
    
    @IBOutlet var skView: SKView!
    
    var hexMapScene: HexMapScene!
    var guiView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hexMapScene = HexMapScene(size: CGSize(width: skView.bounds.width, height: skView.bounds.height))
        hexMapScene.scaleMode = .aspectFill
        
        // Present the scene
        skView.allowsTransparency = true
        skView.presentScene(hexMapScene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        guiView = hexMapScene.hexMapController.setupUI(in: skView)
        
        // Gesture recognizers
        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(panHandler))
        view.addGestureRecognizer(panGestureRecognizer)
        
        /*let clickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(clickHandler))
        view.addGestureRecognizer(clickGestureRecognizer)*/
        
        let zoomGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(zoomHandler))
        view.addGestureRecognizer(zoomGestureRecognizer)
    }
    
    // recognize gestures
    // drag map around
    @objc
    func panHandler(_ gestureRecognize: NSPanGestureRecognizer) {
        // get the position within the view where the gesture event happened.
        let p = gestureRecognize.location(in: skView)
        
        // convert the position within the view to position within the scene
        let scenePoint = skView.convert(p, to: hexMapScene)
        
        switch gestureRecognize.state {
        case .began:
            hexMapScene.dragPositionStart = scenePoint
        case .changed:
            hexMapScene.dragPositionTarget = scenePoint
        case .ended:
            // make the block dynamic again, so it's affected by gravity and other forces.
            hexMapScene.dragPositionTarget = nil
            hexMapScene.dragPositionStart = nil
        default:
            print("unknown state: \(gestureRecognize.state)")
        }
    }
    
    @objc
    func clickHandler(_ gestureRecognize: NSClickGestureRecognizer) {
        // * let's see what was clicked *
        let point = gestureRecognize.location(in: skView)
        
        print("click at \(point)")
        // first, check whether this point is over a node in the gui scene
        /*let guiScenePoint = guiView.convert(point, to: guiScene)
        if guiScene.isOverButton(point: guiScenePoint) {
            guiScene.clickButton(at: guiScenePoint)
        } else {
            if let node = hexMapScene.screenPointToNode(point) {
                hexMapScene.hexMapController.clickedNode(node)
            }
        }*/
    }
    
    @objc
    func zoomHandler(_ gestureRecognize: NSMagnificationGestureRecognizer) {
        hexMapScene.setZoom(delta: gestureRecognize.magnification * 0.5)
    }
    
    // note: this is macOS only! And it does not use a Gesture Recognizer, but assumes that ViewController is first responder.
    override func scrollWheel(with event: NSEvent) {
        hexMapScene.setZoom(delta: event.scrollingDeltaY * 0.1)
    }
    
    override func viewDidLayout() {
        guard guiView != nil && skView != nil else {
            return
        }
        
        guiView.frame = skView.frame
    }
}

