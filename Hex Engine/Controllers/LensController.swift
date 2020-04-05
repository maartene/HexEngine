//
//  LensController.swift
//  Hex Engine
//
//  Created by Maarten Engels on 05/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import Combine
import SpriteKit

final class LensController {
    let scene: SKScene
    let tileWidth: Double
    let tileHeight: Double
    let tileYOffsetFactor: Double

    var coordSpriteMap = [AxialCoord: SKShapeNode]()
    var world: World!
    //var getColorForPlayerFunction: ((UUID) -> SKColor)?

    private var cancellables: Set<AnyCancellable>

    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.cancellables = Set<AnyCancellable>()
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
    }

    func subscribeToCommandsIn(hexMapController: HexMapController, world: World) {
        self.world = world
        hexMapController.$queuedCommands.sink(receiveValue: { [weak self] commands in
            self?.resetLens()
            
            if let currentCommand = commands.first {
                self?.displayLensFor(currentCommand.value)
            }
        }).store(in: &cancellables)
    }
    
    private func resetLens() {
        for lensSprite in coordSpriteMap.values {
            lensSprite.removeAllChildren()
            lensSprite.removeFromParent()
        }
        
        coordSpriteMap.removeAll()
    }
    
    func displayLensFor(_ command: Command) {
        if let ttc = command as? TileTargettingCommand {
            if ttc.hasFilter {
                if let coordsToMark = try? ttc.getValidTargets(in: world) {
                    for coord in coordsToMark {
                        let sprite = SKShapeNode(circleOfRadius: CGFloat(tileWidth / 2.0))
                        sprite.position = HexMapController.hexToPixel(coord, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
                        sprite.fillColor = SKColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
                        sprite.strokeColor = SKColor.red
                        sprite.zPosition = 100
                        coordSpriteMap[coord] = sprite
                        scene.addChild(sprite)
                    }
                }
            }
        }
    }
    
    func reset() {
        resetLens()
        cancellables.removeAll()
    }
}
