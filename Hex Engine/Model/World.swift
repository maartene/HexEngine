//
//  World.swift
//  Hex Engine
//
//  Created by Maarten Engels on 11/05/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

enum IDArrayError: Error {
    case indexOutOfBounds
}

struct World {
    
    var hexMap: HexMap
    private var units = [UUID: Unit]()
    private var cities = [UUID: City]()
    
    var onUnitRemoved: ((Unit) -> Void)?
    
    init(width: Int, height: Int, hexMapFactory: (Int, Int) -> HexMap) {
        self.hexMap = hexMapFactory(width, height)
        
        // TESTING only: add a rabbit to the map
        let unit = Unit.Rabbit(startPosition: AxialCoord(q: 1, r: 2))
        units[unit.id] = unit
        
        // TESTING only: add a city with a fixed command
        var city = City(name: "New City", position: AxialCoord(q: 1, r: 1))
        let buildCommand = city.possibleCommands[0]
        city.buildQueue.append(buildCommand)
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
    
    func nextTurn() -> World {
        print("next turn!")
        var newWorld = self
        for unit in units.values {
            newWorld.units[unit.id] = unit.step(hexMap: hexMap)
        }
    
        for city in cities.values {
            do {
                newWorld = try city.build(in: newWorld, production: 5)
            } catch {
                print(error)
            }
        }
        
        return newWorld
    }
    
    mutating func setPath(for unitID: UUID, path: [AxialCoord]) {
        guard var unit = units[unitID] else {
            print("unit with id \(unitID) not found.")
            return
        }
        
        unit.path = path
        units[unit.id] = unit
    }
    
    func executeCommand(_ command: Command) -> World {
        do {
            return try command.execute(in: self)
        } catch {
            print("An error of type '\(error)' occored. Returning world unchanged.")
            return self
        }
    }
    
    func getCityAt(_ coord: AxialCoord) -> City? {
        return cities.values.filter { city in
            city.position == coord
        }.first
    }
    
    mutating func addCity(_ city: City) {
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
    
    mutating func addUnit(_ unit: Unit) {
        guard units[unit.id] == nil else {
            print("ID \(unit.id) for unit already in use.")
            return
        }
        units[unit.id] = unit
    }
    
    mutating func removeUnit(_ unit: Unit) {
        print("Removing unit \(units.removeValue(forKey: unit.id).debugDescription)")
        onUnitRemoved?(unit)
    }
    
    mutating func replaceBuilder(_ newBuilder: Builder) {
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
    
    mutating func replace(_ city: City) {
        guard cities[city.id] != nil else {
            print("Could not replace city with id \(city.id), because it does not exist in the world.")
            return
        }
        
        cities[city.id] = city
    }
}
