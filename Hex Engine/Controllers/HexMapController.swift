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
import Combine

enum UI_State {
    case map
    case selectTargetTile
}

class HexMapController: ObservableObject {
    //static var instance: HexMapController!
    
    @Published var boxedWorld: WorldBox

    let scene: SKScene
    let tileWidth: Double           // in points
    let tileHeight: Double          // in points
    let tileYOffsetFactor: Double   // what fraction of tileHeight are rows offset in the Y value, in points

    var tileSKSpriteNodeMap = [AxialCoord: TileSprite]()
    
    @Published var guiPlayer: UUID
        
    @Published var uiState = UI_State.map
    @Published var queuedCommands = [UUID: Command]()
    
    @Published var selectedTile: AxialCoord?
    
    // the highlighter is a simple shape that follow the mouse around and gives an visual feedback about what can be clicked/tapped.
    var highlighter: SKShapeNode
    
    var unitController: UnitController
    var cityController: CityController
    var lensController: LensController
    
    var guiPlayerIsCurrentPlayer: Bool {
        guiPlayer == boxedWorld.world.currentPlayer?.id
    }
    
    private var cancellables: Set<AnyCancellable>
    
    static let colors = [SKColor.green, SKColor.blue, SKColor.red, SKColor.yellow]
    
    init(scene: SKScene, world: World, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.cancellables = Set<AnyCancellable>()
        self.scene = scene
        self.boxedWorld = WorldBox(world: world)
        guiPlayer = world.currentPlayer!.id
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
        unitController = UnitController(with: scene, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor, guiPlayer: world.currentPlayer!.id)
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
        
                
        lensController = LensController(with: scene, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        lensController.subscribeToCommandsIn(hexMapController: self, boxedWorld: boxedWorld)
        
        unitController.subscribeToUnitsIn(boxedWorld: boxedWorld, hexMapController: self)
        cityController.subscribeToCitiesIn(boxedWorld: boxedWorld)
        
        boxedWorld.$world.sink(receiveValue: { [weak self] world in
            //print("World updated!")
            guard let hc = self else {
                return
            }
            
            for city in world.cities.values {
                if city.id == hc.cityController.selectedCity {
                    for coord in city.getComponent(GrowthComponent.self)?.workingTiles ?? [] {
                        hc.tileSKSpriteNodeMap[coord]?.tintSprite(color: SKColor.green)
                    }
                }
            }
            
            if let player = world.players[world.playerTurnSequence[world.currentPlayerIndex]] {
                if player.ai == nil {
                    hc.guiPlayer = player.id
                }
            }
            
            hc.showHideTiles(world: world)
        }).store(in: &cancellables)
            
        highlighter.lineWidth = 2
                
        highlighter.zPosition = 0.1
        self.scene.addChild(highlighter)
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
        
        scene.removeAllChildren()
        cancellables.removeAll()
    }
    
    func showMap() {
        for coord in boxedWorld.world.hexMap.getTileCoordinates() {
            let q = coord.q
            let r = coord.r
            
            if boxedWorld.world.hexMap[q,r] != .void {
                let tile = TileSprite(tile: boxedWorld.world.hexMap[q,r], hexPosition: AxialCoord(q: q, r: r))
                
                //tile.anchorPoint = CGPoint(x: tileWidth / 2, y: tileHeight / 2)
                let pos = hexToPixel(AxialCoord(q: q, r: r))
                tile.position = pos
                                
                tileSKSpriteNodeMap[AxialCoord(q: q, r: r)] = tile
                
                scene.addChild(tile)
            }
        }
        //print("Players in world: \(world.players) - GUIPlayer: \(guiPlayer)")
        let player = boxedWorld.world.players[guiPlayer]!
        boxedWorld.world = boxedWorld.world.updateVisibilityForPlayer(player: player)
    }
    
    func middleOfMapInWorldSpace() -> CGPoint {
        return hexToPixel(AxialCoord(q: 0, r: 0))
    }
    
    func coordOfNode(_ node: SKSpriteNode) -> AxialCoord? {
        if let cityNode = node as? CitySprite {
            if let cityID = cityController.getCityForNode(cityNode) {
                if let city = try? boxedWorld.world.getCityWithID(cityID) {
                    return city.position
                }
            }
        } else if let unitNode = node as? UnitSprite {
            // get unit for the node
            if let unitID = unitController.getUnitForNode(unitNode) {
                if let unit = try? boxedWorld.world.getUnitWithID(unitID) {
                    return unit.position
                }
            }
        } else if let tileNode = node as? TileSprite {
            return tileNode.hexPosition
        } else if let lensNode = node as? LensSprite {
            return lensNode.hexPosition
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
                    boxedWorld.executeCommand(ttc)
                    uiState = .map
                    queuedCommands.removeValue(forKey: guiPlayer)
                }
            }
        } else {
            // first, determine what kind of node this is.
            // is it a city?
            if let cityNode = node as? CitySprite {
                print("Clicked city node: \(node)")
                if let cityID = cityController.getCityForNode(node) {
                    if let city = try? boxedWorld.world.getCityWithID(cityID) {
                        cityNode.select()
                        cityController.selectedCity = cityID
                        
                        for coord in city.getComponent(GrowthComponent.self)?.workingTiles ?? [] {
                            tileSKSpriteNodeMap[coord]?.tintSprite(color: SKColor.green)
                        }
                    }
                }
            }
            // is it a unit?
            else if let unitNode = node as? UnitSprite {
                
                print("Clicked unit node: \(node)")
                // get unit for the node
                if let unitID = unitController.getUnitForNode(unitNode) {
                    if let unit = try? boxedWorld.world.getUnitWithID(unitID) {
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
        for coord in (try? boxedWorld.world.getCityWithID(cityController.selectedCity ?? UUID()).getComponent(GrowthComponent.self)?.workingTiles) ?? [] {
            tileSKSpriteNodeMap[coord]?.resetSpriteTint()
        }
        
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
                //tileBecameDeselected?(previousTile)
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
        
    func showHideTiles(world: World) {
        //print("showHideTiles")
        let player = world.players[guiPlayer]!
        
        for coord in tileSKSpriteNodeMap.keys {
            guard let sprite = tileSKSpriteNodeMap[coord] else {
                continue
            }
            sprite.visibility = player.visibilityMap[coord, default: .unvisited]
        }
        
        unitController.showHideUnits(in: world, visibilityMap: player.visibilityMap)
        cityController.showHideCities(in: world, visibilityMap: player.visibilityMap)
    }
}
