//
//  Entity.swift
//  Hex Engine
//
//  Created by Maarten Engels on 17/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation

enum EntityErrors: Error {
    case componentNotFound(componentName: String)
}

protocol Entity {
    var id: UUID { get }
    var name: String { get }
    var owningPlayerID: UUID { get }
    var visibility: Int { get }
    var position: AxialCoord { get set }
    var components: [Component] { get set }
    
    func step(in world: World) -> World
}

extension Entity {
    mutating func replaceComponent(component: Component) {
        if let compIndex = components.firstIndex(where: { type(of: component) == type(of: $0) }) {
            components[compIndex] = component
        }
    }
    
    func getComponent<T: Component>(_ type: T.Type) -> T? {
        if let component = components.first(where: { $0 as? T != nil }) {
            return component as? T
        }
        return nil
    }
    
    func tryGetComponent<T: Component>(_ type: T.Type) throws -> T {
        if let component = components.first(where: { $0 as? T != nil }) {
            return component as! T
        }
        throw EntityErrors.componentNotFound(componentName: String(describing: T.self))
    }
    
    var possibleCommands: [Command] {
        var result = [Command]()
        for component in components {
            result.append(contentsOf: component.possibleCommands)
        }
        return result
    }
    
    func step(in world: World) -> World {
        //print("step for entity \(self.name) (\(self.id))")
        var changedWorld = world
        
        for component in components {
            changedWorld = component.step(in: changedWorld)
        }
        
        return changedWorld
    }
}
