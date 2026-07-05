//
//  MapTab.swift
//  iOS_Demo
//

import SwiftUI

struct MapTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Map coming soon",
                systemImage: "map",
                description: Text("Finished games will drop a pin where you played.")
            )
            .navigationTitle("Map")
        }
    }
}

#Preview {
    MapTab()
}
