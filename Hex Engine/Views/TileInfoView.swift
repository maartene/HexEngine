//
//  TileInfoView.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

struct LabelView {
    static let cornerRadius: CGFloat = 4.0
    static let margin: CGFloat = 10.0
    static let backgroundColor = SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7)
    
    let labelNode: SKLabelNode
    var backgroundNode: SKShapeNode
    let view: SKView
    
    var text = "" {
        didSet {
            labelNode.text = text
            let backgroundColor = backgroundNode.fillColor
            
            labelNode.removeAllChildren()
            
            backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: labelNode.frame.width + 2 * Self.margin, height: labelNode.frame.height + 2 * Self.margin), cornerRadius: Self.cornerRadius)
            
            backgroundNode.position = CGPoint(x: -Self.margin, y: -Self.margin)
            backgroundNode.fillColor = backgroundColor
            backgroundNode.zPosition = -0.05
            
            labelNode.addChild(backgroundNode)
        }
    }
    
    init(text: String, foregroundColor: SKColor = SKColor.white, backgroundColor: SKColor = Self.backgroundColor) {
        labelNode = SKLabelNode(text: text)
        //
        labelNode.fontColor = foregroundColor
        labelNode.horizontalAlignmentMode = .left
        labelNode.verticalAlignmentMode = .bottom
        labelNode.position = CGPoint(x: Self.margin, y: Self.margin)
        
        backgroundNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: labelNode.frame.width + 2 * Self.margin, height: labelNode.frame.height + 2 * Self.margin), cornerRadius: Self.cornerRadius)
        
        backgroundNode.position = CGPoint(x: -Self.margin, y: -Self.margin)
        backgroundNode.fillColor = backgroundColor
        backgroundNode.zPosition = -0.05
        
        labelNode.addChild(backgroundNode)
        
        let frame = CGRect(x: 0, y: 0, width: 400, height: 300)
        let scene = SKScene(size: frame.size)
        scene.backgroundColor = SKColor.clear
        scene.addChild(labelNode)
        
        self.text = text
        
        self.view = SKView(frame: frame)
        view.allowsTransparency = true
        view.presentScene(scene)
    }
}
