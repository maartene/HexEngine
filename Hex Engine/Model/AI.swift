//
//  AI.swift
//  Hex Engine
//
//  Created by Maarten Engels on 30/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import Foundation

protocol AI: Codable {
    // this function should perform all "heavy calculations" in a seperate thread and call "world.nextTurn()" on the main thread when finished.
    func decide(for player: Player, in world: World) -> World
}

extension AI {
    // default implementation of a "brainless AI".
    func performTurn(for playerID: UUID, in world: World) -> World {
        //DispatchQueue.global().async {
            guard let player = world.players[playerID] else {
                print("Player with id \(playerID) not found in world.")
                return world
            }
            
            print("AI processing turn for player \(player.name) (\(player.id))")
            var changedWorld = world
            // skip turn (do nothing)
            changedWorld = self.decide(for: player, in: changedWorld)
            
          //  DispatchQueue.main.async {
            return changedWorld.nextTurn()
          //  }
        //}
    }
    
    func decide(for player: Player, in world: World) -> World{
        //sleep(1)
        return world
    }
}

let allAIs = ["turnSkipAI": TurnSkipAI()]

/// all this AI does, is skip to next turn.
struct TurnSkipAI: AI {}
