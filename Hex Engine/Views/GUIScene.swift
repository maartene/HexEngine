//
//  GUIScene.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

struct GUI {
    static let BACKGROUND_COLOR = SKColor(white: 0.4, alpha: 0.7)
    static let FONT_SIZE: CGFloat = 12
    static let FONT_TYPE = "American Typewriter"
    
    static let CORNER_RADIUS: CGFloat = 4.0
    static let MARGIN: CGFloat = 4.0
    static let PADDING: CGFloat = 4.0
}

final class GUIScene: SKScene {
    var tileInfoLabel: LabelPanel
    var unitInfoLabel: LabelPanel
    
    var viewController: ViewController?
    
    var nextTurnButton: SKButton
    
    override init(size: CGSize) {
        tileInfoLabel = LabelPanel(text: "A lot of text, but multiline doesn't work.")
        tileInfoLabel.position = CGPoint(x: GUI.PADDING, y: GUI.PADDING)

        unitInfoLabel = LabelPanel(text: "Some info about a unit.")
        unitInfoLabel.position = CGPoint(x: GUI.PADDING, y: size.height - 200)
        let button = SKButton(imageNamed: "blue_button06")
        button.isUserInteractionEnabled = true
        unitInfoLabel.addChild(button)
        
        nextTurnButton = SKButton(imageNamed: "blue_button06")
        nextTurnButton.size = CGSize(width: 200, height: 200)
        nextTurnButton.position = CGPoint(x: size.width, y: size.height) - CGPoint(x: nextTurnButton.size.width / 2.0, y:nextTurnButton.size.height)
        
        super.init(size: size)
        
        backgroundColor = SKColor.clear
        addChild(tileInfoLabel)
        addChild(unitInfoLabel)
        addChild(nextTurnButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func connectToScene(scene: HexMapScene) {
        scene.hexMapController.tileBecameSelected = { coord, tile in
            self.tileInfoLabel.isHidden = false
            self.tileInfoLabel.text =
            """
            Tile: \(coord) - \(tile)
            Movement cost: \(tile.costToEnter)
            """
        }
        
        scene.hexMapController.tileBecameDeselected = { coord in
            self.tileInfoLabel.isHidden = true
        }
        
        scene.hexMapController.unitController.unitBecameSelected = { unit in
            self.unitInfoLabel.isHidden = false
            self.unitInfoLabel.text =
            """
            Unit: \(unit.name) - (id: \(unit.id))
            Position: \(unit.position)
            Movement left: \(unit.movement)
            """
            
            if let button = (self.unitInfoLabel.children.compactMap { child in
                child as? SKButton
            }.first) {
                print("Setting button action.")
                button.clickAction = { scene.hexMapController.uiState = .selectTile }
            }
        }
        
        scene.hexMapController.unitController.unitBecameDeselected = { unitID in
            self.unitInfoLabel.isHidden = true
        }
        
        nextTurnButton.clickAction = {
            scene.hexMapController.world.nextTurn()
        }
    }
    
    func isOverButton(point: CGPoint) -> Bool {
        for node in nodes(at: point) {
            if let _ = node as? SKButton {
                return true
            }
        }
        return false
    }
    
    func clickButton(at point: CGPoint) {
        let buttons = nodes(at: point).compactMap { node in
            node as? SKButton
        }
        
        if buttons.count == 0 {
            print("No button at point \(point). No button will be clicked.")
        } else if buttons.count > 1 {
            print("WARNING - there are more than one buttons at \(point). The first one will be clicked.")
        } else {
            // buttons.count == 1
        }
    
        buttons.first?.click()
    }
}
