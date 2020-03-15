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
    @Published var cities = [UUID: City]()
    
    var onUnitRemoved: ((Unit) -> Void)?
    var onVisibilityMapUpdated: (() -> Void)?
    var visibilityMap = [AxialCoord: Bool]()
    var visitedMap = [AxialCoord: Bool]()
    
    var players = [UUID: Player]()
    var playerTurnSequence = [UUID]()
    @Published var currentPlayerIndex = 0
    var currentPlayer: Player? {
        return players[playerTurnSequence[currentPlayerIndex]]
    }
    
    init(playerCount: Int, width: Int, height: Int, hexMapFactory: (Int, Int) -> HexMap) {
        self.hexMap = hexMapFactory(width, height)
        
        for i in 0 ..< playerCount {
            var newPlayer = Player(name: "Player \(i)")
            
            // add a "brain" to all other players.
            if i > 0 {
                newPlayer.ai = TurnSkipAI()
            }
            players[newPlayer.id] = newPlayer
            playerTurnSequence.append(newPlayer.id)
        }
        
        // TESTING only: add a rabbit to the map
        //let unit = Unit.Rabbit(owningPlayer: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: 2))
        let unit = Unit.Snake(owningPlayer: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: 2))
        units[unit.id] = unit
        
        if playerCount > 1 {
            // TESTING only: add another rabbit (with a different owner to the map
            let anotherUnit = Unit.Rabbit(owningPlayer: playerTurnSequence[1], startPosition: AxialCoord(q: -1, r: -1))
            units[anotherUnit.id] = anotherUnit
        }
        
        // TESTING only: add a city with a fixed command
        let city = City(owningPlayer: currentPlayer!.id, name: "New City", position: AxialCoord(q: 1, r: 1))
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
        nextPlayer()
        // process current player
        if let player = currentPlayer {
            for unit in units.values.filter({$0.owningPlayer == player.id}) {
                    units[unit.id] = unit.step(hexMap: hexMap)
                }
            
            for city in cities.values.filter({$0.owningPlayer == player.id}) {
                    do {
                        try city.build(in: self, production: 5)
                    } catch {
                        print(error)
                    }
                }
            
            players[player.id] = player.calculateVisibility(in: self)
            
            
            // if it's an AI, do something
            if let ai = player.ai {
                ai.performTurn(for: player.id, in: self)
            }
        }
        
        onVisibilityMapUpdated?()
    }
    
    func nextPlayer() {
        currentPlayerIndex += 1
        currentPlayerIndex = currentPlayerIndex % players.count
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
        
        updateVisibilityForPlayer(player: currentPlayer!)
    }
    
    func updateVisibilityForPlayer(player: Player) {
        let player = player.calculateVisibility(in: self)
        players[player.id] = player
        onVisibilityMapUpdated?()
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
}
