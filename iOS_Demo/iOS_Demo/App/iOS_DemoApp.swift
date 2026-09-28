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
    @State private var notificationService = NotificationService()
    @State private var audioService = AudioService()
    @State private var didFinishLaunchVideo = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                    .environment(sessionStore)
                    .environment(locationService)
                    .environment(notificationService)
                    .environment(audioService)
                    .task {
                        locationService.requestPermission()
                    }

                if !didFinishLaunchVideo {
                    LaunchVideoView {
                        withAnimation(.easeOut(duration: 0.4)) {
                            didFinishLaunchVideo = true
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
