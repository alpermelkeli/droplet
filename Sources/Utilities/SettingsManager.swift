import Foundation
import SwiftUI

/// Settings manager using UserDefaults for persistence
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @AppStorage("workDuration") var workDuration: Int = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") var longBreakDuration: Int = 15
    @AppStorage("workflowCount") var workflowCount: Int = 4
    @AppStorage("autoStartNextSession") var autoStartNextSession: Bool = true
    @AppStorage("alwaysOnTop") var alwaysOnTop: Bool = false
    @AppStorage("selectedTheme") var selectedThemeRaw: String = "Dark"
    
    // Visual settings
    @AppStorage("timerFontSize") var timerFontSize: Double = 42
    @AppStorage("enableGlow") var enableGlow: Bool = false
    
    var selectedTheme: Theme {
        get { Theme(rawValue: selectedThemeRaw) ?? .dark }
        set { selectedThemeRaw = newValue.rawValue }
    }
    
    private init() {}
}
