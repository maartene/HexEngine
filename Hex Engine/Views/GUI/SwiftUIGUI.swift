//
//  SwiftUIGUI.swift
//  Hex Engine
//
//  Created by Maarten Engels on 26/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SwiftUI
import Combine

struct SwiftUIGUI: View {
    
    @ObservedObject var boxedWorld: WorldBox
    @ObservedObject var unitController: UnitController
    @ObservedObject var hexMapController: HexMapController
    
    init(unitController: UnitController, hexMapController: HexMapController) {
        self.hexMapController = hexMapController
        self.unitController = unitController
        self.boxedWorld = hexMapController.boxedWorld
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                UnitInfoView(unitController: unitController, boxedWorld: boxedWorld, hexMapController: hexMapController).shadow(radius: 4).padding().disabled(hexMapController.guiPlayerIsCurrentPlayer == false)
                Spacer()
                //Text("Number of units in the world: \(world.units.count)")
                CityInfoView(cityController: hexMapController.cityController, hexMapController: hexMapController, boxedWorld: boxedWorld).shadow(radius: 4).padding().transition(.opacity).disabled(hexMapController.guiPlayerIsCurrentPlayer == false)
            }
            
            //Text("SwiftUI for SpriteKit gui!")
            //    .background(Color.gray.opacity(0.5))
            
            Spacer()
            
            HStack(alignment: .bottom) {
                TileInfoLabel(hexMapController: hexMapController).shadow(radius: 4).padding()
                Spacer()
                PlayersView(boxedWorld: boxedWorld).shadow(radius: 4).padding()
                Spacer()
                Button(action:
                    { print("next turn")
                    //print("Units in hexMapController: \(HexMapController.instance.world.allUnits)")
                    //print("number of units: \(self.numberOfUnits)")
                        self.boxedWorld.nextTurn()
                    
                }) {
                    Text("Next Turn")
                        .font(Font.custom("American Typewriter", size: 24))
                        .padding()
                    }
                .background(Color.blue.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
                .shadow(radius: 4)
                .padding()
                .disabled(boxedWorld.isUpdating)
            }
        }.font(Font.custom("American Typewriter", size: 12))
    }
}
/*
struct SwiftUIGUI_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIGUI(world: World(width: 30, height: 30, hexMapFactory: WorldFactory.CreateWorld(width:height:)))
    }
}*/
