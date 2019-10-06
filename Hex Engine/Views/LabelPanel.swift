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
    static let GUI_BACKGROUND_COLOR = SKColor(white: 0.4, alpha: 0.7)
    static let GUI_FONT_SIZE: CGFloat = 12
    static let GUI_FONT_TYPE = "American Typewriter"
    
    static let GUI_CORNER_RADIUS: CGFloat = 4.0
    static let GUI_MARGIN: CGFloat = 4.0
    
    let labelNode: SKLabelNode
    var backgroundNode: SKShapeNode
    
    
    var text = "" {
        didSet {
            labelNode.text = text
            let backgroundColor = backgroundNode.fillColor
            
            labelNode.removeAllChildren()
            
            backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: labelNode.frame.width + 2 * LabelPanel.GUI_MARGIN, height: labelNode.frame.height + 2 * LabelPanel.GUI_MARGIN), cornerRadius: LabelPanel.GUI_CORNER_RADIUS)
            
            backgroundNode.position = CGPoint(x: -LabelPanel.GUI_MARGIN, y: -LabelPanel.GUI_MARGIN)
            backgroundNode.fillColor = backgroundColor
            backgroundNode.zPosition = -0.05
            
            labelNode.addChild(backgroundNode)
        }
    }
    
    init(text: String, foregroundColor: SKColor = SKColor.white, backgroundColor: SKColor = LabelPanel.GUI_BACKGROUND_COLOR) {
        labelNode = SKLabelNode(text: text)
        labelNode.fontSize = LabelPanel.GUI_FONT_SIZE
        labelNode.fontName = LabelPanel.GUI_FONT_TYPE
        labelNode.numberOfLines = 0
        //
        labelNode.fontColor = foregroundColor
        labelNode.horizontalAlignmentMode = .left
        labelNode.verticalAlignmentMode = .bottom
        labelNode.position = CGPoint(x: LabelPanel.GUI_MARGIN, y: LabelPanel.GUI_MARGIN)
        
        backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: labelNode.frame.width + 2 * LabelPanel.GUI_MARGIN, height: labelNode.frame.height + 2 * LabelPanel.GUI_MARGIN), cornerRadius: LabelPanel.GUI_CORNER_RADIUS)
        
        backgroundNode.position = CGPoint(x: -LabelPanel.GUI_MARGIN, y: -LabelPanel.GUI_MARGIN)
        backgroundNode.fillColor = backgroundColor
        backgroundNode.zPosition = -0.05
        
        labelNode.addChild(backgroundNode)
        
        self.text = text
        
        super.init()
        
        self.addChild(labelNode)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
