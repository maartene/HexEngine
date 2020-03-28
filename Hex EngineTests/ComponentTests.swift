//
//  ComponentTests.swift
//  Hex EngineTests
//
//  Created by Maarten Engels on 23/03/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import XCTest
@testable import Hex_Engine

class ComponentTests: XCTestCase {

    var world: World!
    var unitWithAllComponents: Hex_Engine.Unit!
    var cityWithAllComponents: City!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        world = World(playerCount: 1, width: 10, height: 10, hexMapFactory: getTestMap(width:height:))
        
        unitWithAllComponents = Unit(owningPlayer: world.currentPlayer!.id, name: "UnitWithAllComponents")
        let unitID = unitWithAllComponents.id
        unitWithAllComponents.components = [AttackComponent(ownerID: unitID),
                                            HealthComponent(ownerID: unitID),
                                            MovementComponent(ownerID: unitID),
                                            SettlerComponent(ownerID: unitID)]
        
        world.addUnit(unitWithAllComponents)
        
        cityWithAllComponents = City(owningPlayer: world.currentPlayer!.id, name: "CityWithAllComponents", position: AxialCoord.zero)
        let cityID = cityWithAllComponents.id
        cityWithAllComponents.components = [BuildComponent(ownerID: cityID)]
        world.addCity(cityWithAllComponents)
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
    
    func testAttackComponent() throws {
        let attackComponent = unitWithAllComponents.getComponent(AttackComponent.self)
        XCTAssertNotNil(attackComponent)
        
        XCTAssertTrue(attackComponent!.possibleCommands.count > 0)
        
    }
    
    func testHealthComponent() throws {
        if var healthComponent = unitWithAllComponents.getComponent(HealthComponent.self) {
            XCTAssertEqual(healthComponent.currentHitPoints, healthComponent.maxHitPoints)
            XCTAssertGreaterThan(healthComponent.currentHitPoints, 2)
            
            // take a little damage
            healthComponent.takeDamage(amount: healthComponent.currentHitPoints - 1)
            XCTAssertLessThan(healthComponent.currentHitPoints, healthComponent.maxHitPoints)
            
            // regain some health
            let hpBefore = healthComponent.currentHitPoints
            healthComponent.step(in: world)
            XCTAssertGreaterThan(try world.getUnitWithID(unitWithAllComponents.id).getComponent(HealthComponent.self)!.currentHitPoints, hpBefore)
            
            // regain some health
            XCTAssertFalse(healthComponent.isDead)
            healthComponent.takeDamage(amount: healthComponent.currentHitPoints * 10)
            XCTAssertTrue(healthComponent.isDead)
        } else {
            XCTAssertTrue(false)
        }
    }
    
    func testBuildComponent() throws {
        if var buildComponent = cityWithAllComponents.getComponent(BuildComponent.self) {
            
            // this test assumes the buildComponent has a production of at least 1
            XCTAssertGreaterThanOrEqual(buildComponent.production, 1)
            let command = BuildUnitCommand(ownerID: buildComponent.ownerID, unitToBuildName: "Rabbit", productionRequired: buildComponent.production + 1)
            
            // entries in buildQueue should increase from 0 to 1
            XCTAssertEqual(buildComponent.buildQueue.count, 0)
            buildComponent = buildComponent.addToBuildQueue(command)
            XCTAssertEqual(buildComponent.buildQueue.count, 1)
            
            cityWithAllComponents.replaceComponent(component: buildComponent)
            world.replace(cityWithAllComponents)
            
            let unitsInWorld = world.units.count
            
            // Production remaining for command in build queue should decrease
            let productionRemainingBefore = buildComponent.buildQueue.first!.productionRemaining
            buildComponent.step(in: world)
            buildComponent = try world.getCityWithID(cityWithAllComponents.id).getComponent(BuildComponent.self)!
            XCTAssertLessThan(buildComponent.buildQueue.first!.productionRemaining, productionRemainingBefore)
            
            buildComponent.step(in: world)
            buildComponent = try world.getCityWithID(cityWithAllComponents.id).getComponent(BuildComponent.self)!
            // Unit should be done
            XCTAssertEqual(buildComponent.buildQueue.count, 0)
            XCTAssertGreaterThan(world.units.count, unitsInWorld)
        } else {
            XCTAssertTrue(false)
        }
    }
    
    
    
    func testComponentCodable() throws {
        for component in unitWithAllComponents.components {
            let wrappedComponent = try ComponentWrapper.wrapperFor(component)
            
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(wrappedComponent)
            
            let decoder = JSONDecoder()
            let decodedWrappedComponent = try decoder.decode(ComponentWrapper.self, from: encodedData)
            
            let decodedComponent = try decodedWrappedComponent.component()
            
            XCTAssertEqual(component.ownerID, decodedComponent.ownerID)
            XCTAssertEqual("\(type(of: component))", "\(type(of: decodedComponent))")
        }
    }
}
