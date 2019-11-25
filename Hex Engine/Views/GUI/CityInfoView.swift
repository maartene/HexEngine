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
    @ObservedObject var world: World
    
    var city: City? {
        if let cityID = cityController.selectedCity {
            do {
                return try world.getCityWithID(cityID)
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    var body: some View {
        VStack {
            if city == nil {
            } else {
                ZStack {
                    Text("CITY").font(Font.custom("American Typewriter", size: 64)).opacity(0.5)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            ForEach(0 ..< (city?.possibleCommands.count ?? 0)) { number in
                                Button(self.city?.possibleCommands[number].title ?? "") {
                                    self.executeBuildCommand(number: number, city: self.city)
                                }.overlay(Capsule().stroke(lineWidth: 1))
                                    .disabled(self.city?.owningPlayer != self.hexMapController.guiPlayer)
                            }
                        }
                        
                        Text("""
                            City: \(city?.name ?? "nil")
                            Owning player: \(city!.owningPlayer)
                            Build queue length: \(city?.buildQueue.count ?? 0)
                        """)
                    }.padding()
                    .background(Color.gray.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1))
                }
            }
        }
    }
    
    func executeBuildCommand(number: Int, city: City?) {
        guard let city = city else {
            return
        }
        
        let command = city.possibleCommands[number]
        world.executeCommand(command)
    }
}

/*
struct CityInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CityInfoView()
    }
}*/
