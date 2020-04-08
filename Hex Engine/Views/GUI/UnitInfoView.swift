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
    @ObservedObject var boxedWorld: WorldBox
    @ObservedObject var hexMapController: HexMapController
    
    var unit: Unit? {
        if let id = unitController.selectedUnit {
            return try? boxedWorld.world.getUnitWithID(id)
        }
        return nil
    }
    
    var owningPlayerName: String {
        guard let unit = unit else {
            return "unknown unit"
        }
        
        if let player = boxedWorld.world.players[unit.owningPlayerID] {
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
                                ForEach(unit!.possibleCommands, id: \Command.title) { command in
                                    Button(command.title) {
                                        if let ttc = command as? TileTargettingCommand {
                                            self.hexMapController.uiState = UI_State.selectTargetTile
                                            self.hexMapController.queuedCommands[self.unit!.owningPlayerID] = ttc
                                        } else {
                                            self.boxedWorld.executeCommand(command)
                                        }
                                    }.overlay(Capsule().stroke(lineWidth: 1))
                                        .disabled(command.canExecute(in: self.boxedWorld.world) == false || self.unit?.owningPlayerID != self.hexMapController.guiPlayer || self.boxedWorld.isUpdating)
                                }
                            }
                        }
                        Text(unitInfoString())
                    }.padding()
                    .background(Color.gray.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
                }
            }
        }
    }
    
    func unitInfoString() -> String {
        var result = ""
        if let unit = unit {
            result += "Unit: \(unit.name) (\(unit.id))\n"
            result += "Owner: \(owningPlayerName) (\(unit.owningPlayerID))\n"
            result += "Position: \(unit.position.description)\n"
            result += "Actions: \(unit.actionsRemaining.oneDecimal)/2\n"
            if let hc = unit.getComponent(HealthComponent.self) {
                result += "HP: \(hc.currentHitPoints)/\(hc.maxHitPoints)"
            }
            if let bic = unit.getComponent(BuildImprovementComponent.self) {
                result += "Energy: \(bic.currentEnergy)/\(bic.maxEnergy)"
            }
        } else {
            result = "No unit selected"
        }
        return result
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
