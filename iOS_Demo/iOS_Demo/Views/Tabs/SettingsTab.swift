//
//  SettingsTab.swift
//  iOS_Demo
//

import SwiftUI

struct SettingsTab: View {
    @Environment(NotificationService.self) private var notifications
    @Environment(SessionStore.self) private var store

    @AppStorage("settings.dailyChallengeEnabled") private var dailyEnabled = false
    @AppStorage("settings.dailyChallengeHour") private var hour = 19
    @AppStorage("settings.dailyChallengeMinute") private var minute = 0

    @AppStorage("settings.musicEnabled") private var musicEnabled = true
    @AppStorage("settings.hapticsEnabled") private var hapticsEnabled = true

    @State private var showResetConfirm = false

    private var reminderTime: Binding<Date> {
        Binding {
            Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        } set: { newValue in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            hour = components.hour ?? 19
            minute = components.minute ?? 0
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Challenge") {
                    Toggle("Daily reminder", isOn: $dailyEnabled)

                    if dailyEnabled {
                        DatePicker("Remind me at",
                                   selection: reminderTime,
                                   displayedComponents: .hourAndMinute)
                    }
                }

                Section("Sound & Haptics") {
                    Toggle("Music", isOn: $musicEnabled)
                    Toggle("Haptics", isOn: $hapticsEnabled)
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset All Stats", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .appBackground()
            .onChange(of: dailyEnabled) { _, enabled in
                Task { await applyReminder(enabled: enabled) }
            }
            .onChange(of: hour) { _, _ in rescheduleIfEnabled() }
            .onChange(of: minute) { _, _ in rescheduleIfEnabled() }
            .confirmationDialog("Reset all stats?",
                                isPresented: $showResetConfirm,
                                titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAll()
                    for mode in GameMode.allCases {
                        UserDefaults.standard.removeObject(forKey: mode.highScoreKey)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes every recorded game. This can't be undone.")
            }
        }
    }

    @MainActor
    private func applyReminder(enabled: Bool) async {
        if enabled {
            let granted = await notifications.requestPermission()
            if granted {
                notifications.scheduleDailyChallenge(hour: hour, minute: minute)
            } else {
                dailyEnabled = false
            }
        } else {
            notifications.cancelDailyChallenge()
        }
    }

    private func rescheduleIfEnabled() {
        if dailyEnabled {
            notifications.scheduleDailyChallenge(hour: hour, minute: minute)
        }
    }
}

#Preview {
    SettingsTab()
        .environment(SessionStore(context: PersistenceController(inMemory: true).viewContext))
        .environment(NotificationService())
}
