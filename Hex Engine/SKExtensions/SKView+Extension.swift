//
//  SKView+Extension.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

extension SKView {
    override open func scrollWheel(with event: NSEvent) {
        self.scene?.scrollWheel(with: event)
    }
    
}
