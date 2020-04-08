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

    var coordSpriteMap = [AxialCoord: LensSprite]()
    var boxedWorld: WorldBox!
    //var getColorForPlayerFunction: ((UUID) -> SKColor)?

    private var cancellables: Set<AnyCancellable>

    init(with scene: SKScene, tileWidth: Double, tileHeight: Double, tileYOffsetFactor: Double) {
        self.cancellables = Set<AnyCancellable>()
        self.scene = scene
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.tileYOffsetFactor = tileYOffsetFactor
    }

    func subscribeToCommandsIn(hexMapController: HexMapController, boxedWorld: WorldBox) {
        self.boxedWorld = boxedWorld
        hexMapController.$queuedCommands.sink(receiveValue: { [weak self] commands in
            //print("update lens")
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
                if let coordsToMark = try? ttc.getValidTargets(in: boxedWorld.world) {
                    for coord in coordsToMark {
                        let sprite = LensSprite(hexPosition: coord)
                        sprite.tintSprite(color: ttc.lensColor)
                        sprite.position = HexMapController.hexToPixel(coord, tileWidth: tileWidth, tileHeight: tileHeight, tileYOffsetFactor: tileYOffsetFactor)
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

extension AttackCommand {
    var lensColor: SKColor {
        return SKColor.red
    }
}
