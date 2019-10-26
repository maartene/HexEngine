//
//  UnitInfoWindow.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

class UnitInfoWindow: SKNode {
    
    var hexMapController: HexMapController!
    
    var unitToShow: Unit? {
        didSet {
            if let newUnit = unitToShow {
                isHidden = false
                unitInfoLabel.text =
                """
                    Unit: \(newUnit.name) (\(newUnit.id))
                    Position: \(newUnit.position)
                    Movement left: \(newUnit.movement)
                """

                moveButton.position = CGPoint(x: 0, y: buttonY())
                moveButton.resetBackgroundColor()
                
                replaceCommandButtons(for: newUnit)
            } else {
                isHidden = true
            }
        }
    }
    
    let unitInfoLabel: LabelPanel
    let moveButton: Button
    var commandButtons = [Button]()
    
    override init() {
        unitInfoLabel = LabelPanel(text: "Foo\nBar\nBaz")
        //unitInfoLabel.labelNode.numberOfLines = 3
        moveButton = Button(text: "Move")
        
        
        super.init()
        
        moveButton.position = CGPoint(x: 0, y: buttonY())
        
        addChild(unitInfoLabel)
        addChild(moveButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buttonY() -> CGFloat {
        let frame = unitInfoLabel.calculateAccumulatedFrame()
        return frame.height //+ GUI.MARGIN
    }
    
    func removeCommandButtons() {
        removeChildren(in: commandButtons)
        commandButtons.removeAll()
    }
    
    func replaceCommandButtons(for unit: Unit) {
        removeCommandButtons()
        
        for command in unit.possibleCommands {
            let newButton = Button(text: command.title)
            
            var x: CGFloat
            if commandButtons.count > 0 {
                let previousButton = commandButtons.last!
                let frame = previousButton.calculateAccumulatedFrame()
                x = previousButton.position.x + frame.width
            } else {
                let frame = moveButton.calculateAccumulatedFrame()
                x = frame.width
            }
            
            x += GUI.PADDING
            //x += newButton.midPointOfFrame.x
            
            newButton.position = CGPoint(x: x, y: buttonY())
            
            newButton.clickAction = {
                self.hexMapController.world = self.hexMapController.world.executeCommand(command)
            }
            
            commandButtons.append(newButton)
            addChild(newButton)
        }
    }
}
