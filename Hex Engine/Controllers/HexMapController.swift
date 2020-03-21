//
//  HexMapController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 06/04/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation
import SpriteKit
import SwiftUI

enum UI_State {
    case map
    case selectTargetTile
}

class HexMapController: ObservableObject {
    static var instance: HexMapController!
    
    @Published var world: World

    let scene: SKScene
    let tileWidth: Double           // in points
    let tileHeight: Double          // in points
    let tileYOffsetFactor: Double   // what fraction of tileHeight are rows offset in the Y value, in points

    var tileSKSpriteNodeMap = [AxialCoord: TileSprite]()
    
    var guiPlayer: UUID
    
    var tileBecameSelected: ((AxialCoord, Tile) -> Void)?
    var tileBecameDeselected: ((AxialCoord) -> Void)?
    
    @Published var uiState = UI_State.map
    var queuedCommands = [UUID: Command]()
    
    @Published var selectedTile: AxialCoord? {
        didSet {
            if let oldSelectedTile = oldValue {
                tileBecameDeSelected(tile: oldSelectedTile)
            }
            if let newSelectedTile = selectedTile {
                let tile = world.hexMap[newSelectedTile.q, newSelectedTile.r]
                tileBecameSelected?(newSelectedTile, tile)
            }
        }
    }
    
    // the highlighter is a simple shape that follow the mouse around and gives an visual feedback about what can be clicked/tapped.
    var highlighter: SKShapeNode
    
    var unitController: UnitController
    var cityController: CityController
    
    var guiPlayerIsCurrentPlayer: Bool {
        guiPlayer == world.currentPlayer?.id
    }
    
    static let colors = [SKColor.green, SKColor.blue, SKColor.red, SKColor.yellow]
    
    init(scene: SKScene, world: World, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.scene = scene
        self.world = world
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
        unitController = UnitController(with: scene, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        unitController.getColorForPlayerFunction = { playerID in
            if let playerIndex = world.playerTurnSequence.firstIndex(of: playerID) {
                return HexMapController.colors[playerIndex]
            } else {
                return SKColor.white
            }
        }
        
        highlighter = SKShapeNode(circleOfRadius: CGFloat(tileWidth / 2.0))
        cityController = CityController(with: scene, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        cityController.getColorForPlayerFunction = { playerID in
            if let playerIndex = world.playerTurnSequence.firstIndex(of: playerID) {
                return HexMapController.colors[playerIndex]
            } else {
                return SKColor.white
            }
        }
        
        guiPlayer = world.currentPlayer!.id
        
        self.world.onUnitRemoved = unitController.onUnitRemoved
        self.world.onVisibilityMapUpdated = showHideTiles
        Unit.onUnitDies = world.removeUnit
        
        highlighter.lineWidth = 2
        
        world.allUnits.forEach { unit in
            Unit.onUnitCreate?(unit)
        }
        
        world.allCities.forEach { city in
            City.onCityCreate?(city)
        }
        
        highlighter.zPosition = 0.1
        self.scene.addChild(highlighter)
        Self.instance = self
    }
    
    func setupUI(in view: SKView) -> some NSView {
        let gui = SwiftUIGUI(unitController: unitController, hexMapController: self).zIndex(4)
        let guiView = NSHostingView(rootView: gui)
        guiView.frame = scene.view!.frame
        view.addSubview(guiView)
        return guiView
    }
    
    static func hexToPixel(_ hex: AxialCoord, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) -> CGPoint {
        //let x = tileWidth * (sqrt(2.0) * Double(hex.q) + sqrt(2)/2.0 * Double(hex.r))
        //let y = tileHeight * (3.0 / 2 * Double(hex.r))
        let x = tileWidth * (0.5 * Double(hex.r) + Double(hex.q))
        let y = tileHeight * Double(hex.r) * tileYOffsetFactor
        return CGPoint(x: x, y: y)
    }
    
    func hexToPixel(_ hex: AxialCoord) -> CGPoint {
        return Self.hexToPixel(hex, tileWidth: self.tileWidth, tileHeight: self.tileHeight, tileYOffsetFactor: self.tileYOffsetFactor)
    }
    
    /*func pixelToHex(_ point: CGPoint) -> AxialCoord {
        //let x = tileWidth * (sqrt(2.0) * Double(hex.q) + sqrt(2)/2.0 * Double(hex.r))
        //let y = tileHeight * (3.0 / 2 * Double(hex.r))
        //let x = tileWidth * (0.5 * Double(hex.r) + Double(hex.q))
        //let y = tileHeight * Double(hex.r) * 0.75
        let q = (2 * Double(point.y) - Double(point.x)) / tileWidth
        let r = Double(point.y) / tileHeight / 0.75
        let s = -q - r
        
        let cubeCoord = CubeCoord.roundToCubeCoord(fractX: q, fractY: s, fractZ: r)
        
        return cubeCoord.toAxial()
    }*/
    
    func reset() {
        unitController.reset()
        cityController.reset()
        
        for tileSprite in tileSKSpriteNodeMap.values {
            tileSprite.removeAllChildren()
            tileSprite.removeFromParent()
        }
        
        tileSKSpriteNodeMap.removeAll()
    }
    
    func showMap() {
        for coord in world.hexMap.getTileCoordinates() {
            let q = coord.q
            let r = coord.r
            
            if world.hexMap[q,r] != .void {
                let tile = TileSprite(tile: world.hexMap[q,r], hexPosition: AxialCoord(q: q, r: r))
                
                //tile.anchorPoint = CGPoint(x: tileWidth / 2, y: tileHeight / 2)
                let pos = hexToPixel(AxialCoord(q: q, r: r))
                tile.position = pos
                                
                tileSKSpriteNodeMap[AxialCoord(q: q, r: r)] = tile
                
                scene.addChild(tile)
            }
        }
        
        let player = world.players[guiPlayer]!
        world.updateVisibilityForPlayer(player: player)
        //showHideTiles(visibilityMap: player.visibilityMap)
    }
    
    func middleOfMapInWorldSpace() -> CGPoint {
        return hexToPixel(AxialCoord(q: 0, r: 0))
    }
    
    func coordOfNode(_ node: SKSpriteNode) -> AxialCoord? {
        if let cityNode = node as? CitySprite {
            if let cityID = cityController.getCityForNode(cityNode) {
                if let city = try?world.getCityWithID(cityID) {
                    return city.position
                }
            }
        } else if let unitNode = node as? UnitSprite {
            // get unit for the node
            if let unitID = unitController.getUnitForNode(unitNode) {
                if let unit = try? world.getUnitWithID(unitID) {
                    return unit.position
                }
            }
        } else if let tileNode = node as? TileSprite {
            return tileNode.hexPosition
        }
        return nil
    }
    
    func clickedNode(_ node: SKSpriteNode) {
        deselectAll()
        
        // if we are in a state where we need to select a tile, calculate the path.
        if uiState == .selectTargetTile {
            guard let tile = coordOfNode(node) else {
                return
            }
            if let command = queuedCommands[guiPlayer] {
                if var ttc = command as? TileTargettingCommand {
                    ttc.targetTile = tile
                    world.executeCommand(ttc)
                    uiState = .map
                }
            }
        } else {
            // first, determine what kind of node this is.
            // is it a city?
            if let cityNode = node as? CitySprite {
                print("Clicked city node: \(node)")
                if let cityID = cityController.getCityForNode(node) {
                    if (try? world.getCityWithID(cityID)) != nil {
                        cityNode.select()
                        cityController.selectedCity = cityID
                    }
                }
            }
            // is it a unit?
            else if let unitNode = node as? UnitSprite {
                
                print("Clicked unit node: \(node)")
                // get unit for the node
                if let unitID = unitController.getUnitForNode(unitNode) {
                    if let unit = try? world.getUnitWithID(unitID) {
                        unitController.selectUnit(unit)
                        deselectTile()
                        print("clicked unit: \(unit.name)")
                    }
                }
                
            } // is it a tile?
            else if let tileNode = node as? TileSprite {
                print("Clicked tile at coord \(node.position)", node)
                selectTile(tileNode.hexPosition)
                unitController.deselectUnit()
            }
        }
        
    }
    
    func deselectAll() {
        deselectTile()
        unitController.deselectUnit()
        cityController.deselectCity()
    }
    
    func mouseOverNode(_ node: SKSpriteNode) {
        highlighter.position = node.position
        switch uiState {
        case .map:
            highlighter.strokeColor = SKColor.gray
        case .selectTargetTile:
            highlighter.strokeColor = SKColor.red
        }
    }
    
    func deselectTile() {
        if let previousTile = selectedTile {
            if let previousSprite = tileSKSpriteNodeMap[previousTile] {
                previousSprite.removeAllChildren()
                selectedTile = nil
                tileBecameDeselected?(previousTile)
            }
        }
    }
    
    func selectTile(_ tile: AxialCoord) {
        if let sprite = tileSKSpriteNodeMap[tile] {
            let radius = max(sprite.size.width, sprite.size.height) / 2.0
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.zPosition = sprite.zPosition + 0.1
            circle.strokeColor = SKColor.white
            circle.lineWidth = 2.0
            circle.glowWidth = 4.0
            sprite.addChild(circle)
            selectedTile = tile
        }
    }
    
    func tileBecameDeSelected(tile: AxialCoord) {
        print("\(tile) was deselected.")
    }
    
    func showHideTiles() {
        let player = world.players[guiPlayer]!
        
        for coord in tileSKSpriteNodeMap.keys {
            guard let sprite = tileSKSpriteNodeMap[coord] else {
                continue
            }
            sprite.visibility = player.visibilityMap[coord, default: .unvisited]
        }
        
        unitController.showHideUnits(in: world, visibilityMap: player.visibilityMap)
    }
}
