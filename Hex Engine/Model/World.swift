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

class World: ObservableObject, Codable {
    var hexMap: HexMap
    
    @Published var units = [UUID: Unit]()
    @Published var cities = [UUID: City]()
    
    //var onUnitRemoved: ((Unit) -> Void)?
    var onVisibilityMapUpdated: (() -> Void)?
    //var onCurrentPlayerChanged: ((Player) -> Void)?
    //var visibilityMap = [AxialCoord: Bool]()
    //var visitedMap = [AxialCoord: Bool]()
    
    var players = [UUID: Player]()
    var playerTurnSequence = [UUID]()
    @Published var currentPlayerIndex = 0
    var currentPlayer: Player? {
        assert(currentPlayerIndex < playerTurnSequence.count)
        return players[playerTurnSequence[currentPlayerIndex]]
    }
    
    enum CodingKeys: CodingKey {
        case hexMap
        case units
        case cities
        case players
        case playerTurnSequence
        case currentPlayerIndex
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hexMap, forKey: .hexMap)
        try container.encode(units, forKey: .units)
        try container.encode(cities, forKey: .cities)
        try container.encode(players, forKey: .players)
        try container.encode(playerTurnSequence, forKey: .playerTurnSequence)
        try container.encode(currentPlayerIndex, forKey: .currentPlayerIndex)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hexMap = try values.decode(HexMap.self, forKey: .hexMap)
        units = try values.decode([UUID: Unit].self, forKey: .units)
        cities = try values.decode([UUID: City].self, forKey: .cities)
        players = try values.decode([UUID: Player].self, forKey: .players)
        playerTurnSequence = try values.decode([UUID].self, forKey: .playerTurnSequence)
        currentPlayerIndex = try values.decode(Int.self, forKey: .currentPlayerIndex)
        assert(players.count == playerTurnSequence.count)
    }
        
    init(playerCount: Int, width: Int, height: Int, hexMapFactory: (Int, Int) -> HexMap) {
        self.hexMap = hexMapFactory(width, height)
        
        for i in 0 ..< playerCount {
            var newPlayer = Player(name: "Player \(i)")
            
            // add a "brain" to all other players.
            if i > 0 {
                newPlayer.aiName = "turnSkipAI"
            }
            players[newPlayer.id] = newPlayer
            playerTurnSequence.append(newPlayer.id)
        }
        
        // TESTING only: add a rabbit to the map
        let unit = Unit.Rabbit(owningPlayer: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: 2))
        //let unit = Unit.Snake(owningPlayer: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: 2))
        units[unit.id] = unit
        
        let narwhal = Unit.Narwhal(owningPlayer: currentPlayer!.id, startPosition: AxialCoord(q: 2, r: 1))
        units[narwhal.id] = narwhal
	        
        if playerCount > 1 {
            // TESTING only: add another rabbit (with a different owner to the map
            let anotherUnit = Unit.Rabbit(owningPlayer: playerTurnSequence[1], startPosition: AxialCoord(q: -1, r: -1))
            units[anotherUnit.id] = anotherUnit
        }
        
        // TESTING only: add a city with a fixed command
        let city = City(owningPlayer: currentPlayer!.id, name: "New City", position: AxialCoord(q: 1, r: 1), isCapital: true)
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
            // gives units new action points
            for unit in units.values.filter({$0.owningPlayerID == player.id}) {
                var changedUnit = unit
                changedUnit.actionsRemaining = 2.0
                replace(changedUnit)
            }
            
            for unit in units.values.filter({$0.owningPlayerID == player.id}) {
                    unit.step(in: self)
                }
            
            for unit in units.values {
                if unit.getComponent(HealthComponent.self)?.isDead ?? false {
                    removeUnit(unit)
                }
            }
            
            for city in cities.values.filter({$0.owningPlayerID == player.id}) {
                    city.step(in: self)
                }
            
            assert(players.keys.contains(player.id))
            players[player.id] = player.calculateVisibility(in: self)
            
            if let ai = player.ai {
                ai.performTurn(for: player.id, in: self)
            }
        }
        
        onVisibilityMapUpdated?()
    }
    
    func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        assert(players.count == playerTurnSequence.count)
    }
    
    func updateVisibilityForPlayer(player: Player) {
        let player = player.calculateVisibility(in: self)
        assert(players.keys.contains(player.id))
        players[player.id] = player
        onVisibilityMapUpdated?()
    }
    
    func executeCommand(_ command: Command) {
        do {
            try command.execute(in: self)
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
        if let owningPlayer = players[unit.owningPlayerID] {
            updateVisibilityForPlayer(player: owningPlayer)
        }
        //onUnitRemoved?(unit)
    }
    
    /*func replaceBuilder(_ newBuilder: Builder) {
        guard let city = cities[newBuilder.id] else {
            print("Unknown city \(newBuilder)")
            return
        }
        
        guard let builder = newBuilder as? City else {
            print("Passed builder \(newBuilder) is not a city.")
            return
        }
        
        cities[city.id] = builder
    }*/
    
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
        
        if let owningPlayer = players[unit.owningPlayerID] {
            updateVisibilityForPlayer(player: owningPlayer)
        }
    }
}

// MARK: Commands
struct NextTurnCommand: Command, Codable {
    let title = "Next turn"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        world.nextTurn()
    }
}
