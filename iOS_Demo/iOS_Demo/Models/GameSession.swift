//
//  GameSession.swift
//  iOS_Demo
//

import CoreLocation
import Foundation

struct GameSession: Identifiable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D?

    init?(_ object: GameSessionMO) {
        guard let id = object.id,
              let modeRaw = object.mode,
              let mode = GameMode(rawValue: modeRaw),
              let timestamp = object.timestamp else { return nil }

        self.id = id
        self.mode = mode
        self.score = Int(object.score)
        self.timestamp = timestamp
        self.coordinate = object.hasLocation
            ? CLLocationCoordinate2D(latitude: object.latitude, longitude: object.longitude)
            : nil
    }
}
