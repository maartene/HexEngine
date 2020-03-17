//
//  UnitInfoView.swift
//  Hex Engine
//
//  Created by Maarten Engels on 27/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SwiftUI

struct UnitInfoView: View {
    @ObservedObject var unitController: UnitController
    @ObservedObject var world: World
    @ObservedObject var hexMapController: HexMapController
    
    var unit: Unit? {
        if let id = unitController.selectedUnit {
            return try? world.getUnitWithID(id)
        }
        return nil
    }
    
    var owningPlayerName: String {
        guard let unit = unit else {
            return "unknown unit"
        }
        
        if let player = world.players[unit.owningPlayer] {
            return player.name
        } else {
            return "unknown owning player"
        }
    }
    
    var body: some View {
        VStack {
            if unit == nil {
            } else {
                ZStack {
                    Text("UNIT").font(Font.custom("American Typewriter", size: 64)).opacity(0.5)
                    VStack(alignment: .leading) {
                        HStack {
                            if unit!.possibleCommands.count > 0 {
                                ForEach(0 ..< unit!.possibleCommands.count) { number in
                                    Button(self.unit!.possibleCommands[number].title) {
                                        if let ttc = self.unit!.possibleCommands[number] as? TileTargettingCommand {
                                            self.hexMapController.uiState = UI_State.selectTargetTile
                                            self.hexMapController.queuedCommands[self.unit!.owningPlayer] = ttc
                                        } else {
                                            self.world.executeCommand(self.unit!.possibleCommands[number])
                                        }
                                    }.overlay(Capsule().stroke(lineWidth: 1))
                                        .disabled(self.unit!.possibleCommands[number].canExecute(in: self.world) == false || self.unit?.owningPlayer != self.hexMapController.guiPlayer)
                                }
                            }
                        }
                        Text("""
                            Unit: \(unit!.name) (\(unit!.id))
                            Owner: \(owningPlayerName) (\(unit!.owningPlayer))
                            Position: \(unit!.position.description)
                            Movement: \(unit!.movementLeft.oneDecimal)/\(unit!.movement)
                            Health: \(unit!.currentHitPoints.oneDecimal)/\(unit!.maxHitPoints.oneDecimal)
                            Attack: \(unit!.attackPower.oneDecimal) Defense: \(unit!.defencePower.oneDecimal)
                        """)
                    }.padding()
                    .background(Color.gray.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
                }
            }
        }
    }
}

extension Double {
    var oneDecimal: String {
        if (Double(Int(self)) == self) {
            return String(Int(self))
        }
        return String(format: "%.1f", self)
    }
}

/*
struct UnitInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UnitInfoView()
    }
}*/
