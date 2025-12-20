import Foundation
import AppKit
import Sparkle

/// Manages auto-updates using Sparkle framework
class UpdateManager: NSObject, ObservableObject {
    static let shared = UpdateManager()
    
    private var updaterController: SPUStandardUpdaterController!
    
    override init() {
        super.init()
        // Initialize Sparkle updater
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
    
    /// Get the updater for SwiftUI views
    var updater: SPUUpdater {
        return updaterController.updater
    }
    
    /// Manually check for updates
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
    
    /// Check for updates silently in background
    func checkForUpdatesInBackground() {
        updaterController.updater.checkForUpdatesInBackground()
    }
}
