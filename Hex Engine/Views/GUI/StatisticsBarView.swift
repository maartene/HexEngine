//
//  StatisticsBarView.swift
//  Hex Engine
//
//  Created by Maarten Engels on 16/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct StatisticsBarView: View {
    
    @ObservedObject var boxedWorld: WorldBox
    @ObservedObject var hexMapController: HexMapController
    
    @Binding var shouldShowTechSelection: Bool
    
    var guiPlayer: Player {
        boxedWorld.world.players[hexMapController.guiPlayer]!
    }
    
    var body: some View {
        HStack {
            Text(guiPlayer.name).font(Font.custom("American Typewriter", size: 18))
            Text("\(guiPlayer.gold.roundToZero()) 💎").font(Font.custom("American Typewriter", size: 18))
            Button(action: {
                self.shouldShowTechSelection.toggle()
            }, label: {
                Text("Currently researching: \(guiPlayer.currentlyResearchingTechnology?.title ?? "none")")
            }).overlay(Capsule().stroke(lineWidth: 1))
            Spacer()
            Text("Turn: \(boxedWorld.world.turn)").font(Font.custom("American Typewriter", size: 18))
        }.padding(4)
            .background(Color.green.opacity(0.75))
    }
}
