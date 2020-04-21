//
//  CityInfoView.swift
//  Hex Engine
//
//  Created by Maarten Engels on 27/10/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SwiftUI

struct CityInfoView: View {
    @ObservedObject var cityController: CityController
    @ObservedObject var hexMapController: HexMapController
    @ObservedObject var boxedWorld: WorldBox
    
    var city: City? {
        if let cityID = cityController.selectedCity {
            do {
                return try boxedWorld.world.getCityWithID(cityID)
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    struct BuildQueueEntry: Identifiable {
        let id: Int
        let command: BuildCommand
    }
    
    var buildQueue: [BuildQueueEntry] {
        var result = [BuildQueueEntry]()
        
        guard let city = city else {
            return result
        }
        
        guard let buildComponent = city.getComponent(BuildComponent.self) else {
            return result
        }
        
        for enumarated in buildComponent.buildQueue.enumerated() {
            result.append(BuildQueueEntry(id: enumarated.offset, command: enumarated.element))
        }
        
        return result
    }
    
    var possibleUnitBuildCommands: [QueueBuildUnitCommand] {
        (city?.possibleCommands ?? []).compactMap { $0 as? QueueBuildUnitCommand }
    }
    
    var possibleBuildingBuildCommands: [QueueBuildBuildingCommand] {
        (city?.possibleCommands ?? []).compactMap { $0 as? QueueBuildBuildingCommand }
    }
    
    var buildings: String {
        var result = "(empty)"
        
        if let city = city {
            let buildingTitles = city.buildings.map { $0.title }
            result = buildingTitles.joined(separator: ", ")
        }
        
        return result
    }
    
    var body: some View {
        VStack {
            if city == nil {
            } else {
                ZStack {
                    Text("CITY").font(Font.custom("American Typewriter", size: 64)).opacity(0.5)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            ForEach(0 ..< possibleUnitBuildCommands.count) { number in
                                Button(self.possibleUnitBuildCommands[number].title) {
                                    self.executeBuildUnitCommand(number: number)
                                }.overlay(Capsule().stroke(lineWidth: 1))
                                    .disabled(self.city?.owningPlayerID != self.hexMapController.guiPlayer || self.boxedWorld.isUpdating || self.possibleUnitBuildCommands[number].canExecute(in: self.boxedWorld.world) == false)
                            }
                        }
                        
                        HStack {
                            ForEach(0 ..< possibleBuildingBuildCommands.count) { number in
                                Button(self.possibleBuildingBuildCommands[number].title) {
                                    self.executeBuildBuildingCommand(number: number)
                                }.overlay(Capsule().stroke(lineWidth: 1))
                                    .disabled(self.city?.owningPlayerID != self.hexMapController.guiPlayer || self.boxedWorld.isUpdating ||
                                        self.possibleBuildingBuildCommands[number].canExecute(in: self.boxedWorld.world) == false)
                            }
                        }
                        
                        Text("""
                            City: \(city?.name ?? "nil")
                            Owning player: \(city!.owningPlayerID)
                            Population: \(city?.population ?? -1)
                            Saved food: \(city?.savedFood ?? -1)
                            Buildings: \(buildings)
                        """)
                        
                        HStack {
                            Text("Build queue: ")
                            if city?.getComponent(BuildComponent.self)?.buildQueue.count ?? 0 == 0 {
                                Text("empty")
                            } else {
                                ForEach(buildQueue) { buildQueueEntry in
                                    ZStack(alignment: .topTrailing) {
                                        Text(buildQueueEntry.command.title).padding(4)
                                            .background(Color.green.opacity(0.75))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                        
                                        Text("􀁏")
                                            .foregroundColor(Color.red)
                                            .frame(width: 24, height: 24).offset(x: 12, y: -12)
                                            .shadow(radius: 4)
                                            .onTapGesture {
                                                self.removeBuildQueueEntry(buildQueueEntry.id)
                                            //print("remove entry: \(buildQueueEntry)")
                                        }
                                    }
                                }
                            }
                        }
                    }.padding()
                    .background(Color.gray.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
                }
            }
        }
    }
    
    func removeBuildQueueEntry(_ index: Int) {
        guard let city = city else {
            print("city not found")
            return
        }
        
        let command = RemoveFromBuildQueueCommand(ownerID: city.id, commandToRemoveIndex: index)
        boxedWorld.executeCommand(command)
    }
    
    func executeBuildUnitCommand(number: Int) {
        let command = possibleUnitBuildCommands[number]
        boxedWorld.executeCommand(command)
    }
    
    func executeBuildBuildingCommand(number: Int) {
        let command = possibleBuildingBuildCommands[number]
        boxedWorld.executeCommand(command)
    }
}

/*
struct CityInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CityInfoView()
    }
}*/
