//
//  CommandTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 19/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class CommandTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func _testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func _testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMovementCommand() throws {
        var world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let coord = AxialCoord(q: -5, r: -5)
        var unit = Unit(owningPlayer: world.currentPlayer!.id, name: "Rabbit", productionRequired: 5, startPosition: coord)
        unit.components = [MovementComponent(ownerID: unit.id)]
        world.addUnit(unit)
        XCTAssertEqual(unit.getComponent(MovementComponent.self)?.path.count ?? -1, 0)
        let command = MoveUnitCommand(ownerID: unit.id, targetTile: AxialCoord(q: 5, r: 5))
        world = world.executeCommand(command)
        let updatedUnit = try world.getUnitWithID(unit.id)
        XCTAssertNotEqual(updatedUnit.position, unit.position)
        XCTAssertGreaterThan(updatedUnit.getComponent(MovementComponent.self)!.path.count, 1)
    }
    
    func testQueueBuildUnitCommand() throws {
        var world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let city = City(owningPlayer: world.currentPlayer!.id, name: "testplayer", position: AxialCoord.zero)
        world.addCity(city)
        XCTAssertEqual(city.getComponent(BuildComponent.self)?.buildQueue.count, 0)
        let command = QueueBuildUnitCommand(ownerID: city.id, unitToBuildName: "Rabbit")
        world = world.executeCommand(command)
        let updatedCity = try world.getCityWithID(city.id)
        XCTAssertGreaterThan(updatedCity.getComponent(BuildComponent.self)?.buildQueue.count ?? 0, 0)
        XCTAssertTrue(updatedCity.getComponent(BuildComponent.self)?.buildQueue.contains(where: { bc in bc.title == "Build Rabbit" }) ?? false)
    }
    
    func testBuildUnitCommand() throws {
        var world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let city = City(owningPlayer: world.currentPlayer!.id, name: "testplayer", position: AxialCoord.zero)
        world.addCity(city)
        let unitCount = world.units.count
        let command = BuildUnitCommand(ownerID: city.id, unitToBuildName: "Snake")
        world = world.executeCommand(command)
        XCTAssertEqual(world.units.count, unitCount + 1)
        XCTAssertTrue(world.units.contains(where: { unit in unit.value.name == "Snake" }))
    }
    
    func testRemoveFromBuildQueueCommand() throws {
        var world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let city = City(owningPlayer: world.currentPlayer!.id, name: "testplayer", position: AxialCoord.zero)
        world.addCity(city)
        XCTAssertEqual(city.getComponent(BuildComponent.self)?.buildQueue.count, 0)
        let command = QueueBuildUnitCommand(ownerID: city.id, unitToBuildName: "Rabbit")
        world = world.executeCommand(command)
        let updatedCity = try world.getCityWithID(city.id)
        XCTAssertGreaterThan(updatedCity.getComponent(BuildComponent.self)?.buildQueue.count ?? 0, 0)
        XCTAssertTrue(updatedCity.getComponent(BuildComponent.self)?.buildQueue.contains(where: { bc in bc.title == "Build Rabbit" }) ?? false)
        
        let removeCommand = RemoveFromBuildQueueCommand(ownerID: city.id, commandToRemoveIndex: 0)
        world = world.executeCommand(removeCommand)
        let removingCity = try world.getCityWithID(city.id)
        XCTAssertEqual(removingCity.getComponent(BuildComponent.self)?.buildQueue.count ?? 1, 0)
        XCTAssertFalse(removingCity.getComponent(BuildComponent.self)?.buildQueue.contains(where: { bc in bc.title == "Build Rabbit" }) ?? true)
    }
    
    func testFoundCityCommand() throws {
        var world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let coord = AxialCoord(q: 4, r: 4)
        if world.hexMap[coord] != .Grass {
            world.hexMap[coord] = .Grass
        }
        let rabbit = Rabbit(owningPlayer: world.currentPlayer!.id, startPosition: coord)
        XCTAssertNil(world.getCityAt(coord))
        world.addUnit(rabbit)
        
        let cityCount = world.cities.count
        let command = FoundCityCommand(ownerID: rabbit.id)
        world = world.executeCommand(command)
        
        XCTAssertGreaterThan(world.cities.count, cityCount)
        XCTAssertNotNil(world.getCityAt(coord))
    }
    
    func testAttackCommand() throws {
        var world = World(playerCount: 2, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let coord = AxialCoord.zero
        let snake = Snake(owningPlayer: world.currentPlayer!.id, startPosition: coord)
        let rabbit = Rabbit(owningPlayer: world.players[world.playerTurnSequence[world.currentPlayerIndex+1]]!.id, startPosition: AxialCoord(q: 0, r: 1))
        world.addUnit(snake)
        world.addUnit(rabbit)
        world = world.nextTurn()
        world = world.nextTurn()
        //print(world.currentPlayer?.visibilityMap)
        XCTAssertEqual(rabbit.getComponent(HealthComponent.self)!.maxHitPoints, rabbit.getComponent(HealthComponent.self)?.currentHitPoints)
        
        let command = AttackCommand(ownerID: snake.id, targetTile: AxialCoord(q: 0, r: 1), range: 1)
        world = world.executeCommand(command)
        let attackedRabbit = try world.getUnitWithID(rabbit.id)
        XCTAssertGreaterThan(attackedRabbit.getComponent(HealthComponent.self)!.maxHitPoints, attackedRabbit.getComponent(HealthComponent.self)!.currentHitPoints)
    }
    
    func testEnableAutoExploreCommand() throws {
        var world = World(playerCount: 2, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let coord = AxialCoord.zero
        let rabbit = Rabbit(owningPlayer: world.currentPlayer!.id, startPosition: coord)
        world.addUnit(rabbit)
        
        XCTAssertFalse(rabbit.getComponent(AutoExploreComponent.self)?.active ?? true)
        
        let command = EnableAutoExploreCommand(ownerID: rabbit.id)
        world = world.executeCommand(command)
        let updatedRabbit = try world.getUnitWithID(rabbit.id)
        XCTAssertTrue(updatedRabbit.getComponent(AutoExploreComponent.self)?.active ?? false)
        XCTAssertNotEqual(rabbit.position, updatedRabbit.position, "Rabbit should have moved by now.")
    }
    
    func testDisableAutoExploreCommand() throws {
        var world = World(playerCount: 2, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let coord = AxialCoord.zero
        let rabbit = Rabbit(owningPlayer: world.currentPlayer!.id, startPosition: coord)
        world.addUnit(rabbit)
        
        XCTAssertFalse(rabbit.getComponent(AutoExploreComponent.self)?.active ?? true)
        
        let command = EnableAutoExploreCommand(ownerID: rabbit.id)
        world = world.executeCommand(command)
        let updatedRabbit = try world.getUnitWithID(rabbit.id)
        XCTAssertTrue(updatedRabbit.getComponent(AutoExploreComponent.self)?.active ?? false)
        
        let disableCommand = DisableAutoExploreCommand(ownerID: rabbit.id)
        world = world.executeCommand(disableCommand)
        let disabledAERabbit = try world.getUnitWithID(rabbit.id)
        XCTAssertFalse(disabledAERabbit.getComponent(AutoExploreComponent.self)?.active ?? true)
    }
    
    func testBuildTileImprovementCommand() throws {
        var world = World(playerCount: 2, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let coord = AxialCoord.zero
        
        world.hexMap[coord] = .Forest
        
        let beaver = Beaver(owningPlayer: world.currentPlayer!.id, startPosition: coord)
        world.addUnit(beaver)
        
        let command = BuildTileImprovementCommand(ownerID: beaver.id, componentToBuildName: "Camp")
        XCTAssertTrue(command.canExecute(in: world))
        world = world.executeCommand(command)
        XCTAssertNotNil(world.improvements[coord])
        XCTAssertEqual(world.getImprovementAt(coord)!.title, "Camp")
    }
    
    
    func testCommandCodable() throws {
        let commands: [Command] = [AttackCommand(ownerID: UUID(), targetTile: AxialCoord(q: 12, r: 26), range: 4), FoundCityCommand(ownerID: UUID()), MoveUnitCommand(ownerID: UUID(), targetTile: AxialCoord(q: -50, r: 12))]
        
        for command in commands {
            let wrappedCommand = try CommandWrapper.wrapperFor(command: command)
            
            let encoder = JSONEncoder()
            let encodedWrappedCommand = try encoder.encode(wrappedCommand)
            
            let decoder = JSONDecoder()
            let decodedWrappedCommand = try decoder.decode(CommandWrapper.self, from: encodedWrappedCommand)
            
            let decodedCommand = try decodedWrappedCommand.command()
            
            XCTAssertEqual(decodedCommand.ownerID, command.ownerID)
            XCTAssertEqual(decodedCommand.title, command.title)
        }
    }
    
    func testBuildBuildingCommandTest() throws {
        var world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let coord = AxialCoord.zero
        
        var city = City(owningPlayer: world.currentPlayer!.id, name: "Test City", position: coord)
        world.addCity(city)
        XCTAssertFalse(city.buildings.contains(where: {building in building.title == "Granary" }))
        let command = BuildBuildingCommand(ownerID: city.id, buildingToBuildName: "Granary")
        world = world.executeCommand(command)
        city = try world.getCityWithID(city.id)
        XCTAssertTrue(city.buildings.contains(where: {building in building.title == "Granary" }))
    }
    
    func testQueueBuildBuildingCommand() throws {
        var world = World(playerCount: 1, width: 30, height: 30, hexMapFactory: getTestMap(width:height:))
        let city = City(owningPlayer: world.currentPlayer!.id, name: "testplayer", position: AxialCoord.zero)
        world.addCity(city)
        XCTAssertEqual(city.getComponent(BuildComponent.self)?.buildQueue.count, 0)
        let command = QueueBuildBuildingCommand(ownerID: city.id, buildingToBuildName: "Granary")
        world = world.executeCommand(command)
        let updatedCity = try world.getCityWithID(city.id)
        XCTAssertGreaterThan(updatedCity.getComponent(BuildComponent.self)?.buildQueue.count ?? 0, 0)
        XCTAssertTrue(updatedCity.getComponent(BuildComponent.self)?.buildQueue.contains(where: { bc in bc.title == "Build Granary" }) ?? false)
    }
    
}
