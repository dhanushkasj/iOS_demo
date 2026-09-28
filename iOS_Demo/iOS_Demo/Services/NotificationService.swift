//
//  NotificationService.swift
//  iOS_Demo
//

import UserNotifications

@Observable
final class NotificationService {
    private let center = UNUserNotificationCenter.current()
    private let dailyIdentifier = "dailyChallenge"

    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleDailyChallenge(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Your games are waiting — can you beat your best today?"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyIdentifier, content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: [dailyIdentifier])
        center.add(request)
    }

    func cancelDailyChallenge() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyIdentifier])
    }
}
