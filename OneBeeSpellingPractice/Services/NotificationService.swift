//
//  NotificationService.swift
//  One Bee Spelling Practice
//

import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        #if os(iOS)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
        #else
        completion(false)
        #endif
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        #if os(iOS)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["onebee_reminder"])
        let content = UNMutableNotificationContent()
        content.title = "Time to practice!"
        content.body = "Open One Bee Spelling and learn a few words."
        content.sound = .default
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "onebee_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        #endif
    }

    func cancelReminder() {
        #if os(iOS)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["onebee_reminder"])
        #endif
    }
}
