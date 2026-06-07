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
                Text("Tapped Count")
                    .font(.title)
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red)
            
            VStack{
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            
            VStack{
                Text("Timer")
                    .font(.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.yellow)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
