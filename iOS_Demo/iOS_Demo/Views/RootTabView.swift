//
//  RootTabView.swift
//  iOS_Demo
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem { Label("Home", systemImage: "gamecontroller") }

            StatsTab()
                .tabItem { Label("Stats", systemImage: "chart.bar") }

            MapTab()
                .tabItem { Label("Map", systemImage: "map") }

            SettingsTab()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    RootTabView()
        .environment(SessionStore(context: PersistenceController(inMemory: true).viewContext))
}
