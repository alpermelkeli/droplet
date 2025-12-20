import Foundation
import UserNotifications
import AppKit

/// Handles macOS system notifications and sounds for timer events
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            }
            if let error = error {
                print("❌ Notification permission error: \(error)")
            }
        }
    }
    
    /// Play system alert sound
    func playAlertSound() {
        // Play the system "Glass" sound (a pleasant beep)
        NSSound.beep()
        
        // Alternative: play a specific system sound
        if let sound = NSSound(named: "Glass") {
            sound.play()
        }
    }
    
    func sendNotification(title: String, body: String) {
        // Play sound immediately
        playAlertSound()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            } else {
                print("✅ Notification sent: \(title)")
            }
        }
    }
    
    func sendWorkEndNotification() {
        sendNotification(
            title: "Work Session Complete!",
            body: "Time for a break. You've earned it!"
        )
    }
    
    func sendBreakEndNotification() {
        sendNotification(
            title: "Break Over!",
            body: "Ready to focus again?"
        )
    }
    
    func sendLongBreakEndNotification() {
        sendNotification(
            title: "Long Break Over!",
            body: "Great job! Ready for another workflow?"
        )
    }
}
