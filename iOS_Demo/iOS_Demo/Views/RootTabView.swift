//
//  RootTabView.swift
//  iOS_Demo
//

import SwiftUI

struct RootTabView: View {
    @AppStorage("settings.hapticsEnabled") private var hapticsEnabled = true
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            HomeTab()
                .tabItem { Label("Home", systemImage: "gamecontroller") }
                .tag(0)

            StatsTab()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(1)

            MapTab()
                .tabItem { Label("Map", systemImage: "map") }
                .tag(2)

            SettingsTab()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
        }
        .sensoryFeedback(trigger: selection) { _, _ in
            hapticsEnabled ? .selection : nil
        }
    }
}

#Preview {
    RootTabView()
        .environment(SessionStore(context: PersistenceController(inMemory: true).viewContext))
        .environment(LocationService())
        .environment(NotificationService())
        .environment(AudioService())
}
