//
//  CityController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 23/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftUI
import Combine

final class CityController: ObservableObject {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double

    var citySpriteMap = [UUID: CitySprite]()
    var getColorForPlayerFunction: ((UUID) -> SKColor)?
    
    private var cancellables: Set<AnyCancellable>
    
    @Published var selectedCity: UUID?
    
    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.cancellables = Set<AnyCancellable>()
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
    }
    
    func subscribeToCitiesIn( world: World) {
        world.$cities.sink(receiveCompletion: { completion in
            print("Print CityController received completion \(completion) from world.cities")
        }, receiveValue: { [weak self] cities in
            // there are three cases
            
            for cityID in cities.keys {
                
                // case 1: city is known to both CityController and World:
                if self?.citySpriteMap[cityID] != nil, let city = cities[cityID]{
                    self?.updateCitySprite(city: city)
                }
            
                // case 2: city is known to world, but not yet to CityController
                if self?.citySpriteMap[cityID] == nil, let city = cities[cityID] {
                    self?.createCitySprite(city: city)
                }
            }
            
            // case 3: the final case is where a city is known to the CityController, but not the world
            // i.e. when the city is destroyed
            for cityID in (self?.citySpriteMap ?? [UUID: CitySprite]()).keys {
                if cities[cityID] == nil {
                    self?.removeCitySprite(cityID: cityID)
                }
            }
            }).store(in: &cancellables)
    }

    func createCitySprite(city: City) {
        guard citySpriteMap[city.id] == nil else {
            print("A sprite for city already exists. Not creating a second one.")
            return
        }
        
        print("Creating sprite for city \(city.name) (\(city.id))")
        // find a resource for the unit
        let color = getColorForPlayerFunction?(city.owningPlayerID) ?? SKColor.white
        let sprite = CitySprite(city: city, playerColor: color)
        
        sprite.zPosition = 1
        
        // move sprite to correct position
        sprite.position = HexMapController.hexToPixel(city.position, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        citySpriteMap[city.id] = sprite
        
        scene.addChild(sprite)
    }
    
    func getCityForNode(_ node: SKSpriteNode) -> UUID? {
        for pair in citySpriteMap.enumerated() {
            if pair.element.value == node {
                return pair.element.key
            }
        }
        return nil
    }
    
    func deselectCity() {
        guard let cityID = selectedCity else {
            return
        }
        citySpriteMap[cityID]?.deselect()
        selectedCity = nil
    }
    
    func showHideCities(in world: World, visibilityMap: [AxialCoord: TileVisibility]) {
        for cityID in citySpriteMap.keys {
            if let city = try? world.getCityWithID(cityID) {
                if visibilityMap[city.position] ?? .unvisited == .visible {
                    citySpriteMap[cityID]!.alpha = 1
                } else {
                    citySpriteMap[cityID]!.alpha = 0
                }
            }
        }
    }
    
    func reset() {
        for citySprite in citySpriteMap.values {
            citySprite.removeAllChildren()
            citySprite.removeFromParent()
        }
        
        citySpriteMap.removeAll()
        cancellables.removeAll()
    }
    
    func removeCitySprite(cityID: UUID) {
        fatalError("Not implemented")
    }
    
    func updateCitySprite(city: City) {
        if let citySprite = citySpriteMap[city.id] {
            citySprite.updateCity(city: city)
        }
    }
}
