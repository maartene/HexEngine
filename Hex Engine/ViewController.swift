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

class ViewController: NSViewController {

    static let PADDING: CGFloat = 4.0
    
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let scene = HexMapScene(size: CGSize(width: skView.bounds.width, height: skView.bounds.height))
        scene.scaleMode = .aspectFill
        
        let guiView = SKView(frame: skView.frame)
        guiView.allowsTransparency = true
        let guiScene = SKScene(size: skView.frame.size)
        guiScene.backgroundColor = SKColor.clear
        guiView.presentScene(guiScene)
        
        let tileInfoLabel = LabelPanel(text: "A lot of text, but multiline doesn't work.")
        tileInfoLabel.position = CGPoint(x: Self.PADDING, y: Self.PADDING)
        guiScene.addChild(tileInfoLabel)
        scene.hexMapController.tileBecameSelected = { coord, tile in
            tileInfoLabel.text =
            """
            Tile: \(coord) - \(tile)
            Movement cost: \(tile.costToEnter)
            """
        }
        
        let unitInfoLabel = LabelPanel(text: "Some info about a unit.")
        unitInfoLabel.position = CGPoint(x: Self.PADDING, y: skView.frame.height - 200)
        guiScene.addChild(unitInfoLabel)
        scene.hexMapController.unitController.unitBecameSelected = { unit in
            unitInfoLabel.isHidden = false
            unitInfoLabel.text =
            """
            Unit: \(unit.name) - (id: \(unit.id))
            Position: \(unit.position)
            Movement left: \(unit.movement)
            """
        }
        
        scene.hexMapController.unitController.unitBecameDeselected = { unitID in
            unitInfoLabel.isHidden = true
        }
        
        skView.addSubview(guiView)
        
        //scene.becomeFirstResponder()
        
        // Present the scene
        skView.allowsTransparency = true
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
}

