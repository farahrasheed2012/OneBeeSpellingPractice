//
//  NotificationService.swift
//  One Bee Spelling Practice
//

import UserNotifications
import UIKit

final class NotificationService {
    static let shared = NotificationService()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    func scheduleDailyReminder(hour: Int, minute: Int) {
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
    }
    
    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["onebee_reminder"])
    }
}
