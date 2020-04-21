//
//  SelectTechToResearch.swift
//  Hex Engine
//
//  Created by Maarten Engels on 18/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import SwiftUI

struct SelectTechToResearchView: View {
    @ObservedObject var boxedWorld: WorldBox
    @ObservedObject var hexMapController: HexMapController
    
    @Binding var shouldShowTechSelection: Bool
    
    var guiPlayer: Player {
        boxedWorld.world.players[hexMapController.guiPlayer]!
    }
    
    var technologiesForPlayer: [Technology] {
        Technology.Prototypes.filter({tech in
            guiPlayer.technologies.contains(where: { ptech in
                ptech.title == tech.title }) == false
        })
    }
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            VStack {
                Text("TECHNOLOGY").font(Font.custom("American Typewriter", size: 32)).shadow(radius: 4).padding()
                
                Section(header: Text("Currently researching:").padding(.horizontal)) {
                    Text(guiPlayer.currentlyResearchingTechnology?.title ?? "(none)")
                }
                
                Section(header: Text("Available technologies:").padding(.top)) {
                    ForEach(technologiesForPlayer, id: \.title) { tech in
                        Button(action: {
                            self.boxedWorld.executeCommand(StartResearchingTechnology(ownerID: self.guiPlayer.id, technologyToResearch: tech))
                            self.shouldShowTechSelection = false
                        }, label: {
                            Text(tech.title)
                        }).overlay(Capsule().stroke(lineWidth: 1))
                    }
                }
                
                Section(header: Text("Unlocked technologies:").padding(.top)) {
                    ForEach(guiPlayer.technologies, id: \.title) { tech in
                        Text(tech.title)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
            
            Text("􀃰")
                .font(.system(size: 20))
                .foregroundColor(Color.white)
                .padding(.all, 2)
                .shadow(radius: 4)
                .onTapGesture {
                    self.shouldShowTechSelection = false
            }
        }
    }
}
