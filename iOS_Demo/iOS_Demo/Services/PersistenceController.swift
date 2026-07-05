//
//  PersistenceController.swift
//  iOS_Demo
//

import CoreData

@objc(GameSessionMO)
final class GameSessionMO: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var mode: String?
    @NSManaged var score: Int64
    @NSManaged var timestamp: Date?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var hasLocation: Bool
}

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PlayHub",
                                          managedObjectModel: PersistenceController.model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static let model: NSManagedObjectModel = {
        let entity = NSEntityDescription()
        entity.name = "GameSessionMO"
        entity.managedObjectClassName = NSStringFromClass(GameSessionMO.self)

        func attribute(_ name: String,
                       _ type: NSAttributeType,
                       optional: Bool = true,
                       defaultValue: Any? = nil) -> NSAttributeDescription {
            let attribute = NSAttributeDescription()
            attribute.name = name
            attribute.attributeType = type
            attribute.isOptional = optional
            attribute.defaultValue = defaultValue
            return attribute
        }

        entity.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("mode", .stringAttributeType),
            attribute("score", .integer64AttributeType, optional: false, defaultValue: 0),
            attribute("timestamp", .dateAttributeType),
            attribute("latitude", .doubleAttributeType, optional: false, defaultValue: 0.0),
            attribute("longitude", .doubleAttributeType, optional: false, defaultValue: 0.0),
            attribute("hasLocation", .booleanAttributeType, optional: false, defaultValue: false)
        ]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }()
}
