import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    let onBackToMenu: () -> Void
    
    @StateObject private var soundService = SoundService.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "es"
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F5F5DC"),
                    Color(hex: "FAEBD7")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                headerView
                
                // Settings sections
                ScrollView {
                    LazyVStack(spacing: 25) {
                        // Sound settings
                        soundSection
                        
                        // Display settings
                        displaySection
                        
                        // Language settings
                        languageSection
                        
                        // Haptic settings
                        hapticSection
                        
                        // About section
                        aboutSection
                    }
                }
                
                // Back button
                backButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text(NSLocalizedString("settings.title", comment: ""))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "8B4513"))
            }
            
            Text(NSLocalizedString("settings.subtitle", comment: ""))
                .font(.title3)
                .foregroundColor(Color(hex: "8B4513").opacity(0.8))
        }
    }
    
    // MARK: - Sound Section
    private var soundSection: some View {
        SettingsSection(
            title: NSLocalizedString("settings.sound", comment: ""),
            icon: "speaker.wave.2.fill"
        ) {
            VStack(spacing: 15) {
                // Sound toggle
                SettingsToggle(
                    title: NSLocalizedString("settings.sound.effects", comment: ""),
                    subtitle: NSLocalizedString("settings.sound.effects.subtitle", comment: ""),
                    isOn: $soundService.soundEnabled
                )
                
                // Background music toggle
                SettingsToggle(
                    title: NSLocalizedString("settings.music", comment: ""),
                    subtitle: NSLocalizedString("settings.music.subtitle", comment: ""),
                    isOn: $soundService.musicEnabled
                )
                
                // Volume slider
                if soundService.soundEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(NSLocalizedString("settings.volume", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(soundService.volume * 100))%")
                                .font(.caption)
                                .foregroundColor(Color(hex: "8B4513").opacity(0.7))
                        }
                        
                        Slider(value: $soundService.volume, in: 0...1)
                            .accentColor(Color(hex: "8B4513"))
                    }
                    .padding(.leading, 15)
                }
            }
        }
    }
    
    // MARK: - Display Section
    private var displaySection: some View {
        SettingsSection(
            title: NSLocalizedString("settings.display", comment: ""),
            icon: "paintbrush.fill"
        ) {
            SettingsToggle(
                title: NSLocalizedString("settings.dark.mode", comment: ""),
                subtitle: NSLocalizedString("settings.dark.mode.subtitle", comment: ""),
                isOn: $isDarkMode
            )
        }
    }
    
    // MARK: - Language Section
    private var languageSection: some View {
        SettingsSection(
            title: NSLocalizedString("settings.language", comment: ""),
            icon: "globe"
        ) {
            VStack(spacing: 10) {
                ForEach(["es", "en"], id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                    }) {
                        HStack {
                            Text(languageName(for: language))
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "8B4513"))
                            
                            Spacer()
                            
                            if selectedLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "8B4513"))
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedLanguage == language ? Color(hex: "8B4513").opacity(0.1) : Color.clear)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Haptic Section
    private var hapticSection: some View {
        SettingsSection(
            title: NSLocalizedString("settings.haptic", comment: ""),
            icon: "hand.tap.fill"
        ) {
            SettingsToggle(
                title: NSLocalizedString("settings.haptic.feedback", comment: ""),
                subtitle: NSLocalizedString("settings.haptic.feedback.subtitle", comment: ""),
                isOn: $hapticFeedback
            )
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        SettingsSection(
            title: NSLocalizedString("settings.about", comment: ""),
            icon: "info.circle.fill"
        ) {
            VStack(spacing: 12) {
                AboutRow(
                    title: NSLocalizedString("settings.version", comment: ""),
                    value: "1.0.0"
                )
                
                AboutRow(
                    title: NSLocalizedString("settings.developer", comment: ""),
                    value: "iOS Game Studio"
                )
                
                Button(action: {
                    // Open privacy policy URL
                    if let url = URL(string: "https://example.com/privacy") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Text(NSLocalizedString("settings.privacy.policy", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "8B4513"))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(Color(hex: "8B4513").opacity(0.7))
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        Button(action: onBackToMenu) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.title3)
                Text(NSLocalizedString("menu.back", comment: ""))
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .foregroundColor(Color(hex: "8B4513"))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "8B4513"), lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Helper Methods
    private func languageName(for code: String) -> String {
        switch code {
        case "es":
            return "Español"
        case "en":
            return "English"
        default:
            return code
        }
    }
}

// MARK: - Settings Section Component
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Section header
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "8B4513"))
            }
            
            // Section content
            content
                .padding(.leading, 35)
        }
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "D2B48C"), lineWidth: 1)
                )
        )
    }
}

// MARK: - Settings Toggle Component
struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color(hex: "8B4513").opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "8B4513"))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - About Row Component
struct AboutRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(hex: "8B4513"))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(Color(hex: "8B4513").opacity(0.7))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onBackToMenu: {})
            .previewLayout(.sizeThatFits)
    }
}