//
//  iOS_DemoApp.swift
//  iOS_Demo
//
//  Created by Dhanushka Jayakody on 2026-06-06.
//

import SwiftUI

@main
struct iOS_DemoApp: App {
    @State private var sessionStore = SessionStore(context: PersistenceController.shared.viewContext)
    @State private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(sessionStore)
                .environment(locationService)
                .task {
                    locationService.requestPermission()
                }
        }
    }
}
