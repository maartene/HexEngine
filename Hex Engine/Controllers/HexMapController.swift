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
    case selectTile
}

class HexMapController: ObservableObject {
    static var instance: HexMapController!
    
    @State var world: World

    let scene: SKScene
    let tileWidth: Double           // in points
    let tileHeight: Double          // in points
    let tileYOffsetFactor: Double   // what fraction of tileHeight are rows offset in the Y value, in points

    var tileSKSpriteNodeMap = [AxialCoord: SKSpriteNode]()
    
    var tileBecameSelected: ((AxialCoord, Tile) -> Void)?
    var tileBecameDeselected: ((AxialCoord) -> Void)?
    
    @Published var uiState = UI_State.map
    
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
    
    init(scene: SKScene, world: World, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.scene = scene
        self.world = world
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
        unitController = UnitController(with: scene, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        highlighter = SKShapeNode(circleOfRadius: CGFloat(tileWidth / 2.0))
        cityController = CityController(with: scene, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
        
        self.world.onUnitRemoved = unitController.onUnitRemoved
        self.world.onVisibilityMapUpdated = showHideTiles
        
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
        let gui = SwiftUIGUI(world: world, unitController: unitController, hexMapController: self).zIndex(4)
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
    
    func showMap() {
        for coord in world.hexMap.getTileCoordinates() {
            let q = coord.q
            let r = coord.r
            
            if world.hexMap[q,r] != .void {
                let spriteName: String
                switch world.hexMap[q,r] {
                case .Forest:
                    spriteName = "grass_13"
                case .Grass:
                    spriteName = "grass_05"
                case .Mountain:
                    spriteName = "dirt_18"
                case .Sand:
                    spriteName = "sand_07"
                case .Water:
                    spriteName = "water"
                default:
                    spriteName = ""
                }
                let tile = SKSpriteNode(imageNamed: spriteName)
                
                //tile.anchorPoint = CGPoint(x: tileWidth / 2, y: tileHeight / 2)
                let pos = hexToPixel(AxialCoord(q: q, r: r))
                tile.userData = ["q": q, "r": r]
                tile.position = pos
                tile.color = SKColor.white
                tile.colorBlendFactor = 1.0
                
                // add x/y/z coordinates to tile as text
                /*
                let label = SKLabelNode(text: "\(q),\(r)")
                label.zPosition = tile.zPosition + 1
                tile.addChild(label)
                 */
                
                tileSKSpriteNodeMap[AxialCoord(q: q, r: r)] = tile
                
                scene.addChild(tile)
            }
        }
        
        showHideTiles()
    }
    
    func middleOfMapInWorldSpace() -> CGPoint {
        return hexToPixel(AxialCoord(q: 0, r: 0))
    }
    
    func clickedNode(_ node: SKSpriteNode) {
        print("clickedNode: \(node)")
        // first, determine what kind of node this is.
        if cityController.citySpriteMap.values.contains(node) {
            print("Clicked city node: \(node)")
            if let cityID = cityController.getCityForNode(node) {
                if (try? world.getCityWithID(cityID)) != nil {
                    cityController.selectedCity = cityID
                }
            }
        } // is it a unit?
        else if unitController.unitSpriteMap.values.contains(node) {
            
            print("Clicked unit node: \(node)")
            // get unit for the node
            if let unitID = unitController.getUnitForNode(node) {
                if let unit = try? world.getUnitWithID(unitID) {
                    unitController.selectUnit(unit)
                    deselectTile()
                    print("clicked unit: \(unit)")
                }
            }
            
        } // is it a tile?
        else if tileSKSpriteNodeMap.values.contains(node) {
            if let q = node.userData?["q"] as? Int, let r = node.userData?["r"] as? Int {
                print("Clicked tile at coord \(q), \(r)", node)
                deselectTile()
                selectTile(AxialCoord(q: q, r: r))
                unitController.deselectUnit()
            }
        }
        
        // if we are in a state where we need to select a tile, calculate the path.
        if uiState == .selectTile {
            if let unitID = unitController.selectedUnit, let tile = selectedTile {
                let command = MoveUnitCommand(ownerID: unitID, targetPosition: tile)
                world.executeCommand(command)
            }
            uiState = .map
        }
    }
    
    func mouseOverNode(_ node: SKSpriteNode) {
        highlighter.position = node.position
        switch uiState {
        case .map:
            highlighter.strokeColor = SKColor.gray
        case .selectTile:
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
        print("showHideTiles \(tileSKSpriteNodeMap.keys.count)")
        for coord in tileSKSpriteNodeMap.keys {
            guard let sprite = tileSKSpriteNodeMap[coord] else {
                continue
            }
            
            if world.visibilityMap[coord] ?? false {
                sprite.alpha = 1
                sprite.removeAllChildren()
            } else if world.visitedMap[coord] ?? false {
                sprite.alpha = 0.5
                sprite.removeAllChildren()
            } else {
                if sprite.children.count == 0 {
                    let child = SKSpriteNode(imageNamed: "unknown")
                    sprite.addChild(child)
                    child.zPosition = 0.01
                }
            }
        }
    }
}
