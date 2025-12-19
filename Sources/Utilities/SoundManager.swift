import Foundation
import AVFoundation

/// Available ambient sound types
enum AmbientSound: String, CaseIterable, Identifiable {
    case none = "None"
    case forest = "Forest"
    case train = "Train"
    case library = "Library"
    case crickets = "Crickets"
    
    var id: String { rawValue }
    
    var filename: String? {
        switch self {
        case .none: return nil
        case .forest: return "forest"
        case .train: return "train"
        case .library: return "library"
        case .crickets: return "cricket"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "🔇"
        case .forest: return "🌲"
        case .train: return "🚂"
        case .library: return "📚"
        case .crickets: return "🦗"
        }
    }
}

/// Manages ambient sound playback with seamless looping
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var currentSound: AmbientSound = .none
    @Published var volume: Float = 0.5
    @Published var isPlaying: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        // Load saved preferences
        if let savedSound = UserDefaults.standard.string(forKey: "ambientSound"),
           let sound = AmbientSound(rawValue: savedSound) {
            currentSound = sound
        }
        volume = UserDefaults.standard.float(forKey: "soundVolume")
        if volume == 0 { volume = 0.5 } // Default volume
    }
    
    /// Play the specified ambient sound on loop
    func play(_ sound: AmbientSound) {
        stop()
        currentSound = sound
        UserDefaults.standard.set(sound.rawValue, forKey: "ambientSound")
        
        guard let filename = sound.filename else {
            isPlaying = false
            return
        }
        
        // Try to find the sound file in the bundle
        // Supports: mp3, m4a, aac, wav
        let extensions = ["mp3", "m4a", "aac", "wav"]
        var soundURL: URL?
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: filename, withExtension: ext, subdirectory: "Sounds") {
                soundURL = url
                break
            }
            // Also try without subdirectory
            if let url = Bundle.main.url(forResource: filename, withExtension: ext) {
                soundURL = url
                break
            }
        }
        
        guard let url = soundURL else {
            print("⚠️ Sound file not found: \(filename)")
            isPlaying = false
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            print("🔊 Playing: \(sound.rawValue)")
        } catch {
            print("❌ Error playing sound: \(error.localizedDescription)")
            isPlaying = false
        }
    }
    
    /// Stop current playback
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    /// Toggle playback
    func toggle() {
        if isPlaying {
            stop()
        } else if currentSound != .none {
            play(currentSound)
        }
    }
    
    /// Update volume
    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
        audioPlayer?.volume = volume
        UserDefaults.standard.set(volume, forKey: "soundVolume")
    }
    
    /// Increase volume by 10%
    func volumeUp() {
        setVolume(volume + 0.1)
    }
    
    /// Decrease volume by 10%
    func volumeDown() {
        setVolume(volume - 0.1)
    }
}
