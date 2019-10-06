//
//  SKButton.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

class Button: LabelPanel {
    
    var clickAction: (() -> Void)?
    
    func click() {
        print("Clicked me - \(self)")
        clickAction?()
    }
}
