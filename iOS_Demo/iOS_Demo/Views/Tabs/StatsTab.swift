//
//  StatsTab.swift
//  iOS_Demo
//

import SwiftUI

struct StatsTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Stats coming soon",
                systemImage: "chart.bar",
                description: Text("Totals, personal bests and a chart will appear here.")
            )
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsTab()
}
