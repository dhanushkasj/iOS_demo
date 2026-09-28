//
//  SessionStore.swift
//  iOS_Demo
//

import CoreData
import CoreLocation

@Observable
final class SessionStore {
    private(set) var sessions: [GameSession] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        refresh()
    }

    func record(mode: GameMode, score: Int, coordinate: CLLocationCoordinate2D?) {
        let object = GameSessionMO(context: context)
        object.id = UUID()
        object.mode = mode.rawValue
        object.score = Int64(score)
        object.timestamp = Date()

        if let coordinate {
            object.latitude = coordinate.latitude
            object.longitude = coordinate.longitude
            object.hasLocation = true
        }

        save()
    }

    func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GameSessionMO")
        let delete = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(delete)
            context.reset()
        } catch {
            context.rollback()
        }
        refresh()
    }

    private func save() {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
        refresh()
    }

    private func refresh() {
        let request = NSFetchRequest<GameSessionMO>(entityName: "GameSessionMO")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let objects = (try? context.fetch(request)) ?? []
        sessions = objects.compactMap(GameSession.init)
    }
}
