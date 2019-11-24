//
//  TitleScreenView.swift
//  Hex Engine
//
//  Created by Maarten Engels on 17/11/2019.
//  Copyright © 2019 thedreamweb. All rights reserved.
//

import SwiftUI

struct TitleScreenView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .top, endPoint: .bottom)
                VStack {
                    Spacer()
                    Image("logo").resizable().frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    Text("Start Game").font(.largeTitle)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(lineWidth: 4).opacity(0.5))
                        .shadow(radius: 4)
                    Spacer()
                }
            }
        }
    }
}

struct TitleScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TitleScreenView()
    }
}
