//
//  Technology.swift
//  Hex Engine
//
//  Created by Maarten Engels on 15/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

struct Technology: Codable {
    
    static let Prototypes = Bundle.main.decode([Technology].self, from: "technologies.json")
    static func getPrototype(_ title: String) -> Technology {
        guard var tech = Prototypes.first(where: { $0.title == title }) else {
            fatalError("No technology with title \(title) exists.")
        }
        tech.costRemaining = tech.cost
        return tech
    }
    
    let title: String
    let cost: Double
    let prerequisiteTechs: [String]
    var costRemaining: Double
    
    init(title: String, cost: Double, prerequisiteTechs: [String] = []) {
        self.title = title
        self.cost = cost
        costRemaining = cost
        self.prerequisiteTechs = prerequisiteTechs
    }
    
    var completed: Bool {
        return costRemaining <= 0
    }
}
