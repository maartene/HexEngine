//
//  Component.swift
//  Hex Engine
//
//  Created by Maarten Engels on 17/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

protocol Entity {
    var id: UUID { get }
    var position: AxialCoord { get set }
}

protocol Component {
    var owner: Entity { get }
}
