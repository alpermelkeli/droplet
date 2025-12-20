import Foundation
import AppKit

/// Opens GitHub releases page for update checks (Sparkle requires signed DMG)
class UpdateManager: NSObject, ObservableObject {
    static let shared = UpdateManager()
    
    private let releasesURL = "https://github.com/fikretkdincer/droplet/releases/latest"
    
    override init() {
        super.init()
    }
    
    /// Check for updates by opening GitHub releases page
    func checkForUpdates() {
        if let url = URL(string: releasesURL) {
            NSWorkspace.shared.open(url)
        }
    }
}


