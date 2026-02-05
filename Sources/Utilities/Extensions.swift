import SwiftUI

// MARK: - Extension for Bool
extension Bool {
    var int: Int {
        return self ? 1 : 0
    }
}

// MARK: - Extension for Int
extension Int {
    var bool: Bool {
        return self != 0
    }
    
    /// Format as string with proper pluralization
    func formattedString(singular: String, plural: String) -> String {
        return self == 1 ? singular : plural
    }
}

// MARK: - Extension for Array
extension Array {
    
    /// Safe subscript access
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// Split array into chunks
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    /// Remove duplicates while maintaining order
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var result: [Element] = []
        var seen: Set<T> = []
        
        for value in self {
            let key = value[keyPath: keyPath]
            if seen.contains(key) == false {
                seen.insert(key)
                result.append(value)
            }
        }
        
        return result
    }
}

// MARK: - Extension for Date
extension Date {
    
    /// Format date for display
    func formatted(date: DateFormatter.Style = .abbreviated, time: DateFormatter.Style = .omitted) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = date
        formatter.timeStyle = time
        return formatter.string(from: self)
    }
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Get time ago string
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Extension for UserDefaults
extension UserDefaults {
    
    /// Save Codable object
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }
    
    /// Get Codable object
    func getCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    /// Save array of Codable objects
    func setCodableArray<T: Codable>(_ value: [T], forKey key: String) {
        setCodable(value, forKey: key)
    }
    
    /// Get array of Codable objects
    func getCodableArray<T: Codable>(_ type: T.Type, forKey key: String) -> [T] {
        return getCodable([T].self, forKey: key) ?? []
    }
}

// MARK: - Extension for Color
extension Color {
    
    /// Initialize with hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Get hex string from color
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count > 3 {
            a = Float(components[3])
        }
        
        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(a * 255), lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

// MARK: - Extension for View
extension View {
    
    /// Corner radius with specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// Add shadow with consistent parameters
    func classicShadow() -> some View {
        shadow(
            color: Color.black.opacity(0.1),
            radius: AppConstants.UI.shadowRadius,
            x: AppConstants.UI.shadowOffset.width,
            y: AppConstants.UI.shadowOffset.height
        )
    }
    
    /// Add bounce animation
    func bounceEffect() -> some View {
        self
            .scaleEffect(1.0)
            .animation(
                .interpolatingSpring(
                    mass: 1.0,
                    stiffness: 100.0,
                    damping: 10.0,
                    initialVelocity: 0
                ),
                value: UUID()
            )
    }
    
    /// Add conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Add haptic feedback
    func hapticFeedback(_ type: HapticType = .light) -> some View {
        self.onTapGesture {
            let generator = type.feedbackStyle
            if let impact = generator as? UIImpactFeedbackGenerator {
                impact.impactOccurred()
            } else if let notification = generator as? UINotificationFeedbackGenerator {
                notification.notificationOccurred(.success)
            } else if let selection = generator as? UISelectionFeedbackGenerator {
                selection.selectionChanged()
            }
        }
    }
}

// MARK: - Custom Shape for Corner Radius
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Extension for String
extension String {
    
    /// Localize string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Localize with format
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
    
    /// Check if string is empty or whitespace
    var isBlankOrEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Validate email format
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    /// Truncate string to specified length
    func truncated(limit: Int, trailing: String = "...") -> String {
        return count > limit ? String(prefix(limit)) + trailing : self
    }
}

// MARK: - Extension for Bundle
extension Bundle {
    
    /// Get app version
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// Get app build
    var appBuild: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    /// Get app name
    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? "Unknown"
    }
    
    /// Get bundle identifier
    var bundleIdentifier: String {
        return infoDictionary?["CFBundleIdentifier"] as? String ?? "Unknown"
    }
}

// MARK: - Extension for UIScreen
extension UIScreen {
    
    /// Get screen width
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /// Get screen height
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    /// Check if device is iPad
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Check if device is iPhone
    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

// MARK: - Extension for UIDevice
extension UIDevice {
    
    /// Get device model
    var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// Check if device has notch
    var hasNotch: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return false
        }
        
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets.top > 20
        }
        
        return false
    }
}

// MARK: - Logging Helper
func printLog<T>(_ object: T, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let filename = (file as NSString).lastPathComponent
    let timestamp = DateFormatter().string(from: Date())
    print("🔹 [\(timestamp)] [\(level.rawValue)] \(filename):\(line) \(function) - \(object)")
    #endif
}

// MARK: - Result Type for Error Handling
enum AppError: Error, LocalizedError {
    case generic(String)
    case network(String)
    case storage(String)
    case validation(String)
    
    var errorDescription: String? {
        switch self {
        case .generic(let message):
            return message
        case .network(let message):
            return message
        case .storage(let message):
            return message
        case .validation(let message):
            return message
        }
    }
}

// MARK: - Debouncer
class Debouncer: ObservableObject {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}