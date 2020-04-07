//
//  PlayersView.swift
//  Hex Engine
//
//  Created by Maarten Engels on 16/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SwiftUI

struct PlayersView: View {
    @ObservedObject var boxedWorld: WorldBox
    
    
    var body: some View {
        ZStack {
            Text("PLAYERS").font(Font.custom("American Typewriter", size: 64)).opacity(0.5)
            VStack {
                ForEach (boxedWorld.world.playerTurnSequence, id: \.self) { playerID in
                    Text("\(self.getPlayerName(playerID)) (\(playerID))").background( playerID == self.boxedWorld.world.currentPlayer?.id ? Color.blue : Color.clear)
                }
            }
            .padding() .background(Color.gray.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
        }
    }
    
    func getPlayerName(_ playerID: UUID) -> String {
        return boxedWorld.world.players[playerID]?.name ?? "unknown"
    }
}

/*struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
    }
}*/
