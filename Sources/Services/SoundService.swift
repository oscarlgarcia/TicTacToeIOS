import Foundation
import AVFoundation
import Combine

// MARK: - Sound Types
enum SoundType: String, CaseIterable {
    case move = "move"
    case win = "win"
    case draw = "draw"
    case gameStart = "game_start"
    case buttonTap = "button_tap"
    case achievement = "achievement"
    case error = "error"
    
    var fileName: String {
        return rawValue
    }
    
    var fileExtension: String {
        return "mp3"
    }
}

// MARK: - Music Types
enum MusicType: String, CaseIterable {
    case background = "background_music"
    case menu = "menu_music"
    case victory = "victory_fanfare"
    
    var fileName: String {
        return rawValue
    }
    
    var fileExtension: String {
        return "mp3"
    }
    
    var volume: Float {
        switch self {
        case .background, .menu:
            return 0.3
        case .victory:
            return 0.6
        }
    }
}

// MARK: - Sound Service
class SoundService: NSObject, ObservableObject {
    static let shared = SoundService()
    
    // MARK: - Published Properties
    @Published var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled")
            if musicEnabled {
                startBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }
    
    @Published var volume: Float {
        didSet {
            UserDefaults.standard.set(volume, forKey: "soundVolume")
            backgroundMusicPlayer?.volume = volume
        }
    }
    
    // MARK: - Private Properties
    private var soundPlayers: [SoundType: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession
    
    // MARK: - Initialization
    override init() {
        // Load settings from UserDefaults
        self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        self.musicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled")
        self.volume = UserDefaults.standard.float(forKey: "soundVolume")
        
        // Set default values if not set
        if !UserDefaults.standard.bool(forKey: "soundSettingsInitialized") {
            self.soundEnabled = true
            self.musicEnabled = true
            self.volume = 0.5
            UserDefaults.standard.set(true, forKey: "soundSettingsInitialized")
        }
        
        // Setup audio session
        do {
            self.audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
            self.audioSession = AVAudioSession.sharedInstance()
        }
        
        super.init()
        
        setupSounds()
        
        if musicEnabled {
            startBackgroundMusic()
        }
    }
    
    deinit {
        stopBackgroundMusic()
    }
    
    // MARK: - Public Methods
    
    /// Play a sound effect
    func playSound(_ type: SoundType) {
        guard soundEnabled else { return }
        
        if let player = soundPlayers[type] {
            player.currentTime = 0
            player.play()
        } else {
            // If player not available, try to load it
            loadSound(type)
            soundPlayers[type]?.play()
        }
    }
    
    /// Play background music
    func playBackgroundMusic(_ type: MusicType = .background) {
        guard musicEnabled else { return }
        
        loadBackgroundMusic(type)
        backgroundMusicPlayer?.play()
    }
    
    /// Stop background music
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    /// Start background music (app launch)
    func startBackgroundMusic() {
        playBackgroundMusic(.background)
    }
    
    /// Pause background music (app backgrounded)
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    /// Resume background music (app foregrounded)
    func resumeBackgroundMusic() {
        guard musicEnabled else { return }
        backgroundMusicPlayer?.play()
    }
    
    // MARK: - Private Methods
    
    private func setupSounds() {
        for soundType in SoundType.allCases {
            loadSound(soundType)
        }
    }
    
    private func loadSound(_ type: SoundType) {
        guard let url = Bundle.main.url(forResource: type.fileName, withExtension: type.fileExtension) else {
            print("Could not find sound file: \(type.fileName).\(type.fileExtension)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            soundPlayers[type] = player
        } catch {
            print("Could not load sound file: \(error)")
        }
    }
    
    private func loadBackgroundMusic(_ type: MusicType) {
        guard let url = Bundle.main.url(forResource: type.fileName, withExtension: type.fileExtension) else {
            print("Could not find music file: \(type.fileName).\(type.fileExtension)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = volume * type.volume
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.prepareToPlay()
        } catch {
            print("Could not load music file: \(error)")
        }
    }
    
    // MARK: - System Sound Integration
    
    /// Play haptic feedback with sound
    func playHapticWithSound(_ type: SoundType, style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        // Play sound
        playSound(type)
        
        // Play haptic
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    /// Play selection sound with light haptic
    func playSelectionFeedback() {
        playSound(.buttonTap)
        
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    /// Play notification sound with notification haptic
    func playNotificationFeedback(_ type: SoundType = .achievement) {
        playSound(type)
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
}

// MARK: - Sound Manager Extensions
extension SoundService {
    
    /// Mute all sounds temporarily
    func muteAll() {
        let wasSoundEnabled = soundEnabled
        let wasMusicEnabled = musicEnabled
        
        soundEnabled = false
        musicEnabled = false
        
        // Store previous state for restoration
        UserDefaults.standard.set(wasSoundEnabled, forKey: "previousSoundEnabled")
        UserDefaults.standard.set(wasMusicEnabled, forKey: "previousMusicEnabled")
    }
    
    /// Restore previous sound settings
    func restoreAll() {
        let wasSoundEnabled = UserDefaults.standard.bool(forKey: "previousSoundEnabled")
        let wasMusicEnabled = UserDefaults.standard.bool(forKey: "previousMusicEnabled")
        
        soundEnabled = wasSoundEnabled
        musicEnabled = wasMusicEnabled
        
        if musicEnabled {
            startBackgroundMusic()
        }
    }
    
    /// Fade out background music
    func fadeOutMusic(duration: TimeInterval = 2.0) {
        guard let player = backgroundMusicPlayer else { return }
        
        let initialVolume = player.volume
        let fadeSteps = 20
        let fadeInterval = duration / Double(fadeSteps)
        
        for step in 1...fadeSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeInterval * Double(step)) {
                player.volume = initialVolume * (1.0 - Double(step) / Double(fadeSteps))
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            player.stop()
            player.volume = initialVolume
        }
    }
    
    /// Fade in background music
    func fadeInMusic(duration: TimeInterval = 2.0) {
        guard musicEnabled else { return }
        
        playBackgroundMusic()
        guard let player = backgroundMusicPlayer else { return }
        
        let targetVolume = volume
        let fadeSteps = 20
        let fadeInterval = duration / Double(fadeSteps)
        
        player.volume = 0
        
        for step in 1...fadeSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeInterval * Double(step)) {
                player.volume = targetVolume * (Double(step) / Double(fadeSteps))
            }
        }
    }
}

// MARK: - Sound Constants
struct SoundConstants {
    static let fadeInDuration: TimeInterval = 1.0
    static let fadeOutDuration: TimeInterval = 1.5
    static let maxVolume: Float = 1.0
    static let defaultVolume: Float = 0.5
    static let backgroundMusicVolume: Float = 0.3
}

// MARK: - Audio Session Helper
extension SoundService {
    
    /// Configure audio session for different app states
    func configureAudioSession(for state: AppState) {
        do {
            switch state {
            case .active:
                try audioSession.setActive(true)
                resumeBackgroundMusic()
            case .background:
                try audioSession.setActive(false)
                pauseBackgroundMusic()
            case .inactive:
                try audioSession.setActive(false)
                stopBackgroundMusic()
            }
        } catch {
            print("Failed to configure audio session for state \(state): \(error)")
        }
    }
    
    enum AppState {
        case active
        case background
        case inactive
    }
}

// MARK: - Sound Analytics
extension SoundService {
    
    /// Track sound usage for analytics
    func trackSoundUsage(_ type: SoundType) {
        // Analytics tracking could be implemented here
        let key = "soundUsage_\(type.rawValue)"
        let currentCount = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(currentCount + 1, forKey: key)
    }
    
    /// Get most frequently used sounds
    func getMostUsedSounds() -> [SoundType] {
        var soundUsage: [(SoundType, Int)] = []
        
        for type in SoundType.allCases {
            let count = UserDefaults.standard.integer(forKey: "soundUsage_\(type.rawValue)")
            soundUsage.append((type, count))
        }
        
        return soundUsage
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
    }
}