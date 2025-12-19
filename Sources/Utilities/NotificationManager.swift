import Foundation
import UserNotifications

/// Handles macOS system notifications for timer events
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    func sendWorkEndNotification() {
        sendNotification(
            title: "Work Session Complete! 💧",
            body: "Time for a break. You've earned it!"
        )
    }
    
    func sendBreakEndNotification() {
        sendNotification(
            title: "Break Over! 🌿",
            body: "Ready to focus again?"
        )
    }
    
    func sendLongBreakEndNotification() {
        sendNotification(
            title: "Long Break Over! 🌊",
            body: "Great job! Ready for another workflow?"
        )
    }
}
