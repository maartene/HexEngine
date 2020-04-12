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

struct World: Codable {
    var hexMap: HexMap
    
    var units = [UUID: Unit]()
    var cities = [UUID: City]()
    var improvements = [AxialCoord: TileImprovement]()
    
    //var onVisibilityMapUpdated: (() -> Void)?
    
    var players = [UUID: Player]()
    var playerTurnSequence = [UUID]()
    var currentPlayerIndex = 0
    
    var currentPlayer: Player? {
        assert(currentPlayerIndex < playerTurnSequence.count)
        return players[playerTurnSequence[currentPlayerIndex]]
    }
    
    enum CodingKeys: CodingKey {
        case hexMap
        case units
        case cities
        case improvements
        case players
        case playerTurnSequence
        case currentPlayerIndex
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hexMap, forKey: .hexMap)
        try container.encode(units, forKey: .units)
        try container.encode(cities, forKey: .cities)
        try container.encode(improvements, forKey: .improvements)
        try container.encode(players, forKey: .players)
        try container.encode(playerTurnSequence, forKey: .playerTurnSequence)
        try container.encode(currentPlayerIndex, forKey: .currentPlayerIndex)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hexMap = try values.decode(HexMap.self, forKey: .hexMap)
        units = try values.decode([UUID: Unit].self, forKey: .units)
        cities = try values.decode([UUID: City].self, forKey: .cities)
        improvements = try values.decode([AxialCoord: TileImprovement].self, forKey: .improvements)
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
        let unit = Unit.getPrototype(unitName: "Rabbit", for: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: 2))
        //let unit = Unit.Rabbit(owningPlayer: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: 2))
        //let unit = Unit.Snake(owningPlayer: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: 2))
        units[unit.id] = unit
        
        let narwhal = Unit.getPrototype(unitName: "Narwhal", for: currentPlayer!.id, startPosition: AxialCoord(q: 2, r: 1))
        units[narwhal.id] = narwhal
        
        let anotherRabbit = Unit.getPrototype(unitName: "Rabbit", for: currentPlayer!.id, startPosition: AxialCoord(q: 1, r: -1))
        units[anotherRabbit.id] = anotherRabbit
        
        if playerCount > 1 {
            // TESTING only: add another rabbit (with a different owner to the map
            let anotherUnit = Unit.getPrototype(unitName: "Rabbit", for: playerTurnSequence[1], startPosition: AxialCoord(q: -1, r: -1))
            units[anotherUnit.id] = anotherUnit
        }
        
        /*for _ in 0 ..< 100 {
            let newUnit = Unit.Rabbit(owningPlayer: players.randomElement()!.key, startPosition: hexMap.getTileCoordinates().randomElement() ?? AxialCoord.zero)
            units[newUnit.id] = newUnit
            let command = EnableAutoExploreCommand(ownerID: newUnit.id)
            self = executeCommand(command)
        }*/
        
        // TESTING only: add a city with a fixed command
        let city = City(owningPlayer: currentPlayer!.id, name: "New City", position: AxialCoord(q: 1, r: 1), isCapital: true)
        cities[city.id] = city
        
        
        // save unit prototypes
        /*let id = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let units = [Unit.Rabbit(owningPlayer: id, startPosition: AxialCoord.zero), Unit.Beaver(owningPlayer: id, startPosition: AxialCoord.zero), Unit.Crocodile(owningPlayer: id, startPosition: AxialCoord.zero), Unit.Narwhal(owningPlayer: id, startPosition: AxialCoord.zero), Unit.Reindeer(owningPlayer: id, startPosition: AxialCoord.zero)]
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(units)
        print(String(data: data, encoding: .utf8)!)
        */
        
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
    
    func getPlayerWithID(_ id: UUID) throws -> Player {
        if let player = players[id] {
            return player
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
        var updatedWorld = self
        updatedWorld = updatedWorld.nextPlayer()
        // process current player
        
        if let player = updatedWorld.currentPlayer {
            // gives units new action points
            for unit in updatedWorld.units.values.filter({$0.owningPlayerID == player.id}) {
                var changedUnit = unit
                changedUnit.actionsRemaining = 2.0
                updatedWorld.replace(changedUnit)
            }
            
            for unit in updatedWorld.units.values.filter({$0.owningPlayerID == player.id}) {
                    updatedWorld = unit.step(in: updatedWorld)
                }
            
            for unit in updatedWorld.units.values {
                if unit.getComponent(HealthComponent.self)?.isDead ?? false {
                    updatedWorld.removeUnit(unit)
                }
            }
            
            for city in updatedWorld.cities.values.filter({$0.owningPlayerID == player.id}) {
                    updatedWorld = city.step(in: updatedWorld)
                }
            
            assert(updatedWorld.players.keys.contains(player.id))
            updatedWorld = updatedWorld.updateVisibilityForPlayer(player: player)
            
            if let ai = player.ai {
                updatedWorld = ai.performTurn(for: player.id, in: updatedWorld)
            }
        }
        
        return updatedWorld
    }
    
    func nextPlayer() -> World {
        var changedWorld = self
        changedWorld.currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        assert(players.count == playerTurnSequence.count)
        return changedWorld
    }
    
    func updateVisibilityForPlayer(player: Player) -> World {
        var updatedWorld = self
        let player = player.calculateVisibility(in: self)
        assert(players.keys.contains(player.id))
        updatedWorld.players[player.id] = player
        return updatedWorld
        //onVisibilityMapUpdated?()
    }
    
    func executeCommand(_ command: Command) -> World {
        do {
            return try command.execute(in: self)
        } catch {
            print("An error of type '\(error)' occored.")
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
        if let owningPlayer = players[unit.owningPlayerID] {
            self = updateVisibilityForPlayer(player: owningPlayer)
        }
    }
    
    mutating func replace(_ city: City) {
        guard cities[city.id] != nil else {
            print("Could not replace city with id \(city.id), because it does not exist in the world.")
            return
        }
        
        cities[city.id] = city
    }
    
    mutating func replace(_ unit: Unit) {
        guard units[unit.id] != nil else {
            print("Could not replace unit with id \(unit.id), because it does not exist in the world.")
            return
        }
        
        units[unit.id] = unit
        
        if let owningPlayer = players[unit.owningPlayerID] {
            self = updateVisibilityForPlayer(player: owningPlayer)
        }
    }
    
    mutating func replace(_ player: Player) {
        guard players[player.id] != nil else {
            print("Could not replace player with id \(player.id), because it does not exist in the world.")
            return
        }
        
        players[player.id] = player
    }
    
    func addImprovement(_ improvement: TileImprovement) throws -> World {
        guard improvements[improvement.position] == nil else {
            throw TileImprovement.TileImprovementErrors.tileAlreadyOccupiedError
        }
        
        var changedWorld = self
        changedWorld.improvements[improvement.position] = improvement
        return changedWorld
    }
    
    func getImprovementAt(_ coord: AxialCoord) -> TileImprovement? {
        return improvements[coord]
    }
    
    func getTileYield(for coord: AxialCoord) -> Tile.TileYield {
        let baseYield = hexMap[coord].baseTileYield
        
        let yieldFromImprovement = getImprovementAt(coord)?.updateTileYield(baseYield) ?? baseYield
        
        return yieldFromImprovement
    }
}

// MARK: Commands
/*struct NextTurnCommand: Command, Codable {
    let title = "Next turn"
    
    var ownerID: UUID
    
    func execute(in world: World) throws {
        world.nextTurn()
    }
}*/
