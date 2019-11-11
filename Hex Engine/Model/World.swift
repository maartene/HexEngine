//
//  World.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum IDArrayError: Error {
    case indexOutOfBounds
}

class World: ObservableObject {
    var hexMap: HexMap
    var executedCommands = [CommandWrapper]()
    
    @Published var units = [UUID: Unit]()
    private var cities = [UUID: City]()
    
    var onUnitRemoved: ((Unit) -> Void)?
    var onVisibilityMapUpdated: (() -> Void)?
    
    var visibilityMap = [AxialCoord: Bool]()
    var visitedMap = [AxialCoord: Bool]()
    
    init(width: Int, height: Int, hexMapFactory: (Int, Int) -> HexMap) {
        self.hexMap = hexMapFactory(width, height)
        
        // TESTING only: add a rabbit to the map
        let unit = Unit.Rabbit(startPosition: AxialCoord(q: 1, r: 2))
        units[unit.id] = unit
        
        // TESTING only: add a city with a fixed command
        let city = City(name: "New City", position: AxialCoord(q: 1, r: 1))
        cities[city.id] = city
    }
    
    func getUnitsOnTile(_ tile: AxialCoord) -> [Unit] {
        return units.values.filter { unit in
            unit.position.q == tile.q && unit.position.r == tile.r
        }
    }
    
    func getUnitWithID(_ id: UUID) throws -> Unit {
        if let unit = units[id] {
            return unit
        } else {
            throw IDArrayError.indexOutOfBounds
        }
    }
    
    func getCityWithID(_ id: UUID) throws -> City {
        if let city = cities[id] {
            return city
        } else {
            throw IDArrayError.indexOutOfBounds
        }
    }
    
    var allUnits: [Unit] {
        return Array(units.values)
    }
    
    var allCities: [City] {
        return Array(cities.values)
    }
    
    func nextTurn() {
        for unit in units.values {
            units[unit.id] = unit.step(hexMap: hexMap)
        }
    
        for city in cities.values {
            do {
                try city.build(in: self, production: 5)
            } catch {
                print(error)
            }
        }
        calculateVisibility()
    }
    
    func setPath(for unitID: UUID, path: [AxialCoord], moveImmediately: Bool = false) {
        guard var unit = units[unitID] else {
            print("unit with id \(unitID) not found.")
            return
        }
        
        unit.path = path
        
        if moveImmediately {
            unit.move(hexMap: hexMap)
        }
        
        units[unit.id] = unit
        calculateVisibility()
    }
    
    func executeCommand(_ command: Command) {
        do {
            try command.execute(in: self)
            try executedCommands.append(CommandWrapper.wrapperFor(command: command))
            /*let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(executedCommands)
            let url = URL(fileURLWithPath: "world.json")
            print(url)
            try data.write(to: url)*/
        } catch {
            print("An error of type '\(error)' occored.")
        }
    }
    
    func getCityAt(_ coord: AxialCoord) -> City? {
        return cities.values.filter { city in
            city.position == coord
        }.first
    }
    
    func addCity(_ city: City) {
        guard cities[city.id] == nil else {
            print("ID \(city.id) for city already in use.")
            return
        }
        
        guard getCityAt(city.position) == nil else {
            print("There is already a city at location: \(city.position).")
            return
        }
        
        cities[city.id] = city
    }
    
    func addUnit(_ unit: Unit) {
        guard units[unit.id] == nil else {
            print("ID \(unit.id) for unit already in use.")
            return
        }
        units[unit.id] = unit
    }
    
    func removeUnit(_ unit: Unit) {
        print("Removing unit \(units.removeValue(forKey: unit.id).debugDescription)")
        onUnitRemoved?(unit)
    }
    
    func replaceBuilder(_ newBuilder: Builder) {
        guard let city = cities[newBuilder.id] else {
            print("Unknown city \(newBuilder)")
            return
        }
        
        guard let builder = newBuilder as? City else {
            print("Passed builder \(newBuilder) is not a city.")
            return
        }
        
        cities[city.id] = builder
    }
    
    func replace(_ city: City) {
        guard cities[city.id] != nil else {
            print("Could not replace city with id \(city.id), because it does not exist in the world.")
            return
        }
        
        cities[city.id] = city
    }
    
    func replace(_ unit: Unit) {
        guard units[unit.id] != nil else {
            print("Could not replace unit with id \(unit.id), because it does not exist in the world.")
            return
        }
        
        units[unit.id] = unit
    }
    
    func calculateVisibility() {
        print("Calculate visibility")
        for coord in hexMap.getTileCoordinates() {
            visibilityMap[coord] = false
        }
        
        for unit in units.values {
            visibilityMap[unit.position] = true
            visitedMap[unit.position] = true
            let visibleNeighbours = HexMap.getAxialNeighbourCoordinates(tile: unit.position)
            for neighbour in visibleNeighbours {
                visibilityMap[neighbour] = true
                visitedMap[neighbour] = true
            }
        }
        
        for city in cities.values {
            visibilityMap[city.position] = true
            visitedMap[city.position] = true
            let visibleNeighbours = HexMap.getAxialNeighbourCoordinates(tile: city.position)
            for neighbour in visibleNeighbours {
                visibilityMap[neighbour] = true
                visitedMap[neighbour] = true
            }
        }
        
        onVisibilityMapUpdated?()
    }
}
