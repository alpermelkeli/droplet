import Foundation
import AppKit
import Sparkle

/// Manages auto-updates using Sparkle framework with EdDSA signing
class UpdateManager: NSObject, ObservableObject {
    static let shared = UpdateManager()
    
    private var updaterController: SPUStandardUpdaterController!
    
    override init() {
        super.init()
        // Initialize Sparkle updater (uses EdDSA signing, not Apple code signing)
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
    
    /// Manually check for updates
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

