//
//  SettingsTab.swift
//  iOS_Demo
//

import SwiftUI

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Settings coming soon",
                systemImage: "gear",
                description: Text("Daily reminders and a reset option will live here.")
            )
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTab()
}
