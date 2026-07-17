//
//  MapTab.swift
//  iOS_Demo
//

import MapKit
import SwiftUI

struct MapTab: View {
    @Environment(SessionStore.self) private var store
    @State private var selectedID: UUID?
    @State private var camera: MapCameraPosition = .automatic

    private var located: [GameSession] {
        store.sessions.filter { $0.coordinate != nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if located.isEmpty {
                    ContentUnavailableView(
                        "No places yet",
                        systemImage: "mappin.slash",
                        description: Text("Finish a game with location access on and it'll drop a pin where you played.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .appBackground()
                } else {
                    map
                }
            }
            .navigationTitle("Map")
        }
    }

    private var map: some View {
        Map(position: $camera, selection: $selectedID) {
            ForEach(located) { session in
                Marker(session.mode.title,
                       systemImage: session.mode.systemImage,
                       coordinate: session.coordinate!)
                    .tint(session.mode.color)
                    .tag(session.id)
            }
        }
        .overlay(alignment: .bottom) {
            if let session = located.first(where: { $0.id == selectedID }) {
                selectionCard(session)
            }
        }
    }

    private func selectionCard(_ session: GameSession) -> some View {
        HStack(spacing: 14) {
            Image(systemName: session.mode.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(session.mode.color, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(session.mode.title)
                    .font(.headline)
                Text(session.timestamp, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text("\(session.score)")
                    .font(.title.bold())
                    .monospacedDigit()
                Text("score")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}

#Preview {
    let store = SessionStore(context: PersistenceController(inMemory: true).viewContext)
    store.record(mode: .tapFrenzy, score: 42,
                 coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090))
    store.record(mode: .quizRush, score: 88,
                 coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278))
    return MapTab().environment(store)
}
