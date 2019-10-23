//
//  SKNode+Extension.swift
//  Hex Engine
//
//  Created by Maarten Engels on 23/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    var midPointOfFrame: CGPoint {
        let frame = self.calculateAccumulatedFrame()
        return CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
    }
}
