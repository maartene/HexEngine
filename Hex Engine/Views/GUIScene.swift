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
    var unitInfoWindow: UnitInfoWindow
    
//    var viewController: ViewController?
    
    var nextTurnButton: Button
    
    override init(size: CGSize) {
        tileInfoLabel = LabelPanel(text: "A lot of text, but multiline doesn't work.")
        tileInfoLabel.position = CGPoint(x: GUI.PADDING, y: GUI.PADDING)

        unitInfoWindow = UnitInfoWindow()
        let unitInfoWindowSize = unitInfoWindow.calculateAccumulatedFrame()
        unitInfoWindow.position = CGPoint(x: GUI.PADDING, y: size.height - unitInfoWindowSize.height - GUI.PADDING)
        unitInfoWindow.isHidden = true
        
        nextTurnButton = Button(text: "Next turn")
        nextTurnButton.setFontSize(to: 24.0)
        let nextTurnButtonSize = nextTurnButton.calculateAccumulatedFrame()
        nextTurnButton.position = CGPoint(x: size.width, y: 0) + CGPoint(x: -nextTurnButtonSize.width, y: 0) + CGPoint(x: -GUI.PADDING, y: GUI.PADDING)
        
        super.init(size: size)
        
        backgroundColor = SKColor.clear
        addChild(tileInfoLabel)
        addChild(nextTurnButton)
        addChild(unitInfoWindow)
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
            self.unitInfoWindow.unitToShow = unit
            
            let button = self.unitInfoWindow.moveButton
            button.clickAction = {
                scene.hexMapController.uiState = .selectTile
                button.changeBackgroundColor(to: SKColor.red)
            }
        }
        
        scene.hexMapController.unitController.unitBecameDeselected = { unitID in
            self.unitInfoWindow.unitToShow = nil
        }
        
        self.unitInfoWindow.hexMapController = scene.hexMapController
        
        nextTurnButton.clickAction = {
            scene.hexMapController.world = scene.hexMapController.world.nextTurn()
        }
    }
    
    func isOverButton(point: CGPoint) -> Bool {
        for node in nodes(at: point) {
            if let _ = node as? Button {
                return true
            }
        }
        return false
    }
    
    func clickButton(at point: CGPoint) {
        let buttons = nodes(at: point).compactMap { node in
            node as? Button
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
