import SwiftUI

/// Main timer display view
struct TimerView: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @ObservedObject var settings = SettingsManager.shared
    
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background with glassmorphism effect
            RoundedRectangle(cornerRadius: 12)
                .fill(settings.selectedTheme.backgroundColor.opacity(0.95))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                // Timer display - using elegant Avenir Next font with dynamic size
                Text(viewModel.formattedTime)
                    .font(.custom("Avenir Next", size: settings.timerFontSize))
                    .fontWeight(.medium)
                    .foregroundColor(settings.selectedTheme.textColor)
                    .monospacedDigit()
                    .opacity(viewModel.status == .pulsing ? (pulseAnimation ? 0.5 : 1.0) : 1.0)
                    .minimumScaleFactor(0.5)
                    .shadow(
                        color: settings.enableGlow ? viewModel.currentAccentColor.opacity(0.6) : .clear,
                        radius: settings.enableGlow ? 8 : 0
                    )
                
                // Progress bar (conditionally shown)
                if settings.showProgressBar {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(settings.selectedTheme.textColor.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(viewModel.currentAccentColor)
                                .frame(width: geometry.size.width * viewModel.progressRatio, height: 4)
                                .animation(.linear(duration: 0.5), value: viewModel.progressRatio)
                                .shadow(
                                    color: settings.enableGlow ? viewModel.currentAccentColor.opacity(0.8) : .clear,
                                    radius: settings.enableGlow ? 6 : 0
                                )
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 20)
                }
                
                // Workflow counter - shows current progress
                // Work: current workflow highlighted (completedWorkflows + 1)
                // Break: completed workflows highlighted
                // Long break: all highlighted (celebration!)
                HStack(spacing: 4) {
                    ForEach(0..<settings.workflowCount, id: \.self) { index in
                        let isHighlighted: Bool = {
                            if viewModel.currentMode == .longBreak {
                                return true  // All lit during long break
                            } else if viewModel.currentMode == .work {
                                return index <= viewModel.completedWorkflows  // Current + completed
                            } else {
                                return index < viewModel.completedWorkflows  // Just completed
                            }
                        }()
                        Circle()
                            .fill(isHighlighted ? 
                                  viewModel.currentAccentColor : 
                                  settings.selectedTheme.textColor.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(minWidth: 140, minHeight: 100)
        .onTapGesture(count: 2) {
            viewModel.resetCurrentMode()
        }
        .onTapGesture(count: 1) {
            if viewModel.status == .pulsing {
                viewModel.continueToNextPhase()
            } else {
                viewModel.toggleStartPause()
            }
        }
        .overlay(
            // Native right-click handler using NSViewRepresentable
            RightClickHandler(viewModel: viewModel, settings: settings)
                .allowsHitTesting(true)
        )
        .onAppear {
            startPulseAnimationIfNeeded()
        }
        .onChange(of: viewModel.status) { newStatus in
            if newStatus == .pulsing {
                startPulseAnimation()
            } else {
                pulseAnimation = false
            }
        }
    }
    
    private func startPulseAnimationIfNeeded() {
        if viewModel.status == .pulsing {
            startPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
}

/// Settings menu content for context menu
struct SettingsMenuContent: View {
    @ObservedObject var viewModel: PomodoroViewModel
    @ObservedObject var settings: SettingsManager
    // Access singletons directly instead of @ObservedObject to prevent refresh issues
    private var soundManager: SoundManager { SoundManager.shared }
    private var launchManager: LaunchAtLoginManager { LaunchAtLoginManager.shared }
    var onQuit: () -> Void
    
    var body: some View {
        Group {
            // Ambient Sounds
            Menu("Sounds") {
                ForEach(AmbientSound.allCases) { sound in
                    Button {
                        if sound == .none {
                            soundManager.stop()
                            soundManager.currentSound = .none
                        } else {
                            soundManager.play(sound)
                        }
                    } label: {
                        HStack {
                            Text(sound.rawValue)
                            if soundManager.currentSound == sound && sound != .none {
                                Text("✓")
                            }
                        }
                    }
                }
                
                Divider()
                
                // Volume controls
                Button("Volume Up") {
                    soundManager.volumeUp()
                }
                .disabled(!soundManager.isPlaying)
                
                Button("Volume Down") {
                    soundManager.volumeDown()
                }
                .disabled(!soundManager.isPlaying)
            }
            
            Divider()
            
            // Duration settings
            Menu("Work Duration") {
                ForEach([10, 15, 20, 25, 30, 45, 50, 60], id: \.self) { minutes in
                    Button("\(minutes) min") {
                        settings.workDuration = minutes
                    }
                }
            }
            
            Menu("Break Duration") {
                ForEach([3, 5, 10, 15], id: \.self) { minutes in
                    Button("\(minutes) min") {
                        settings.shortBreakDuration = minutes
                    }
                }
            }
            
            Menu("Long Break Duration") {
                ForEach([10, 15, 20, 30], id: \.self) { minutes in
                    Button("\(minutes) min") {
                        settings.longBreakDuration = minutes
                    }
                }
            }
            
            Divider()
            
            // Workflow count
            Menu("Workflows Before Long Break") {
                ForEach([2, 3, 4, 5, 6], id: \.self) { count in
                    Button("\(count) workflows") {
                        settings.workflowCount = count
                    }
                }
            }
            
            // End current session
            Button("End Session") {
                viewModel.endCurrentSession()
            }
            
            Divider()
            
            // Toggles
            Toggle("Auto-start Next Session", isOn: $settings.autoStartNextSession)
            Toggle("Always on Top", isOn: $settings.alwaysOnTop)
            
            // Launch at Login toggle
            Toggle("Launch at Login", isOn: Binding(
                get: { launchManager.isEnabled },
                set: { launchManager.setEnabled($0) }
            ))
            
            Divider()
            
            // Theme selector
            Menu("Theme") {
                ForEach(Theme.allCases) { theme in
                    Button(theme.rawValue) {
                        settings.selectedTheme = theme
                    }
                }
            }
            
            // Visual settings
            Menu("Visuals") {
                // Font size control
                Menu("Font Size") {
                    ForEach([16, 24, 32, 42, 52, 64], id: \.self) { size in
                        Button("\(size)px\(Int(settings.timerFontSize) == size ? " ✓" : "")") {
                            settings.timerFontSize = Double(size)
                        }
                    }
                }
                
                Divider()
                
                Toggle("Enable Glow", isOn: $settings.enableGlow)
                Toggle("Show Progress Bar", isOn: $settings.showProgressBar)
            }
            
            Divider()
            
            Button("Check for Updates") {
                UpdateManager.shared.checkForUpdates()
            }
            
            Button("Quit droplet") {
                onQuit()
            }
            .keyboardShortcut("q")
        }
    }
}

/// Native right-click handler using NSViewRepresentable
struct RightClickHandler: NSViewRepresentable {
    let viewModel: PomodoroViewModel
    let settings: SettingsManager
    
    func makeNSView(context: Context) -> RightClickNSView {
        let view = RightClickNSView()
        view.viewModel = viewModel
        view.settings = settings
        return view
    }
    
    func updateNSView(_ nsView: RightClickNSView, context: Context) {
        nsView.viewModel = viewModel
        nsView.settings = settings
    }
}

/// Custom NSView that captures only right-click events
class RightClickNSView: NSView {
    var viewModel: PomodoroViewModel?
    var settings: SettingsManager?
    private var settingsMenu: SettingsMenu?
    
    override func rightMouseDown(with event: NSEvent) {
        guard let viewModel = viewModel, let settings = settings else { return }
        
        settingsMenu = SettingsMenu(viewModel: viewModel, settings: settings)
        let menu = settingsMenu!.createMenu()
        
        // Show menu at mouse location
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    // Pass through all other events to the superview
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Check if this is from a right-click - if not, return nil to pass through
        let currentEvent = NSApp.currentEvent
        if currentEvent?.type == .rightMouseDown {
            return super.hitTest(point)
        }
        // For all other events (left click, etc), pass through to SwiftUI
        return nil
    }
}


