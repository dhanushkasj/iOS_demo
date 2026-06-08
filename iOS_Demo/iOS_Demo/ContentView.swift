//
//  ContentView.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-06-06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0){
            VStack{
                Text("SCORE")
                    .font(.headline)
                    
                Text("0")
                    .font(.largeTitle.bold())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            VStack{
                Button{
                    print("Tapped")
                } label: {
                    ZStack{
                        Circle()
                            .stroke(lineWidth: 8)
                        
                        Circle()
                            .fill(Color.blue)
                            .padding(10)
                        
                        Text("Tap To Start")
                            .foregroundStyle(.white)
                            .font(.largeTitle.bold())
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            VStack{
                Text("TIME REMAINING")
                    .font(.headline)
                Text("00.00")
                    .font(.largeTitle)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
