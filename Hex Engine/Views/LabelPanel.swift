//
//  LabelPanel.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

class LabelPanel: SKNode {
    let labelNode: SKLabelNode
    var backgroundNode: SKShapeNode

    var text = "" {
        didSet {
            labelNode.text = text
            recreateBackground()
        }
    }
    
    init(text: String, foregroundColor: SKColor = SKColor.white, backgroundColor: SKColor = GUI.BACKGROUND_COLOR) {
        labelNode = SKLabelNode(text: text)
        labelNode.fontSize = GUI.FONT_SIZE
        labelNode.fontName = GUI.FONT_TYPE
        labelNode.numberOfLines = 0
        //
        labelNode.fontColor = foregroundColor
        labelNode.horizontalAlignmentMode = .left
        labelNode.verticalAlignmentMode = .bottom
        labelNode.position = CGPoint(x: GUI.MARGIN, y: GUI.MARGIN)
        
        backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: labelNode.frame.width + 2 * GUI.MARGIN, height: labelNode.frame.height + 2 * GUI.MARGIN), cornerRadius: GUI.CORNER_RADIUS)
        
        backgroundNode.position = CGPoint(x: -GUI.MARGIN, y: -GUI.MARGIN)
        backgroundNode.fillColor = backgroundColor
        backgroundNode.zPosition = -0.05
        
        labelNode.addChild(backgroundNode)
        
        self.text = text
        
        super.init()
        
        self.addChild(labelNode)
    }
    
    func setFontSize(to size: CGFloat) {
        labelNode.fontSize = size
        
        recreateBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func recreateBackground() {
        let backgroundColor = backgroundNode.fillColor
        
        labelNode.removeAllChildren()
        
        backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: labelNode.frame.width + 2 * GUI.MARGIN, height: labelNode.frame.height + 2 * GUI.MARGIN), cornerRadius: GUI.CORNER_RADIUS)
        
        backgroundNode.position = CGPoint(x: -GUI.MARGIN, y: -GUI.MARGIN)
        backgroundNode.fillColor = backgroundColor
        backgroundNode.zPosition = -0.05
        
        labelNode.addChild(backgroundNode)
    }
    
    func changeBackgroundColor(to color: SKColor) {
        backgroundNode.fillColor = color
        recreateBackground()
    }
    
    // Reset the background color to the GUI default value
    func resetBackgroundColor() {
        changeBackgroundColor(to: GUI.BACKGROUND_COLOR)
    }
}
