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
                
            } else {
                isHidden = true
            }
        }
    }
    
    let unitInfoLabel: LabelPanel
    let moveButton: Button
    
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
    
    func buttonY() -> CGFloat {
        let frame = unitInfoLabel.calculateAccumulatedFrame()
        return frame.height - GUI.MARGIN
    }
}
