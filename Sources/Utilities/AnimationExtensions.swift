import SwiftUI

// MARK: - Animation Extensions
extension View {
    
    /// Classic elegant bounce animation
    func classicBounce() -> some View {
        self
            .scaleEffect(0.8)
            .animation(.interpolatingSpring(
                mass: 1.0,
                stiffness: 100.0,
                damping: 10.0,
                initialVelocity: 0
            ), value: UUID())
    }
    
    /// Smooth fade-in animation
    func elegantFadeIn(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .animation(.easeInOut(duration: 0.6).delay(delay), value: UUID())
    }
    
    /// Slide in from left animation
    func slideInFromLeft(delay: Double = 0) -> some View {
        self
            .offset(x: -UIScreen.main.bounds.width)
            .animation(.easeOut(duration: 0.8).delay(delay), value: UUID())
    }
    
    /// Slide in from right animation
    func slideInFromRight(delay: Double = 0) -> some View {
        self
            .offset(x: UIScreen.main.bounds.width)
            .animation(.easeOut(duration: 0.8).delay(delay), value: UUID())
    }
    
    /// Pulse animation for highlighting
    func classicPulse() -> some View {
        self
            .overlay(
                self
                    .scaleEffect(1.05)
                    .opacity(0.8)
                    .animation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                        value: UUID()
                    )
            )
    }
    
    /// Winner celebration animation
    func winnerAnimation() -> some View {
        self
            .scaleEffect(1.2)
            .rotationEffect(.degrees(5))
            .animation(
                .interpolatingSpring(
                    mass: 1.0,
                    stiffness: 80.0,
                    damping: 8.0,
                    initialVelocity: 10
                ),
                value: UUID()
            )
    }
}

// MARK: - Animation Manager
class AnimationManager: ObservableObject {
    static let shared = AnimationManager()
    
    @Published var isAnimating = false
    
    private init() {}
    
    // MARK: - Game Animations
    
    /// Animate cell selection with classic elegance
    func animateCellSelection() {
        withAnimation(.interpolatingSpring(
            mass: 0.5,
            stiffness: 200.0,
            damping: 15.0,
            initialVelocity: 0
        )) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                self.isAnimating = false
            }
        }
    }
    
    /// Animate winning line appearance
    func animateWinningLine() {
        withAnimation(.easeInOut(duration: 1.5)) {
            isAnimating = true
        }
    }
    
    /// Animate game reset
    func animateGameReset() {
        withAnimation(.easeInOut(duration: 0.8)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.4)) {
                self.isAnimating = false
            }
        }
    }
    
    /// Animate menu transitions
    func animateMenuTransition() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isAnimating = true
        }
    }
}

// MARK: - Custom Animation View Modifiers

struct ShakeEffect: GeometryEffect {
    let amount: CGFloat
    let shakesPerUnit = 3
    var animatableData: CGFloat
    
    init(amount: CGFloat = 10, shakesPerUnit: Int = 3) {
        self.amount = amount
        self.animatableData = 0
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

struct PulsingEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct RotatingEffect: ViewModifier {
    @State private var isRotating = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 2.0)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

struct FadeInScaleEffect: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.5)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(
                .interpolatingSpring(
                    mass: 1.0,
                    stiffness: 100.0,
                    damping: 10.0
                ).delay(delay),
                value: isVisible
            )
            .onAppear {
                isVisible = true
            }
    }
}

// MARK: - View Extension for Custom Effects
extension View {
    func shake(amount: CGFloat = 10, shakes: Int = 3) -> some View {
        self.modifier(ShakeEffect(amount: amount, shakesPerUnit: shakes))
    }
    
    func pulse() -> some View {
        self.modifier(PulsingEffect())
    }
    
    func rotate() -> some View {
        self.modifier(RotatingEffect())
    }
    
    func fadeInScale(delay: Double = 0) -> some View {
        self.modifier(FadeInScaleEffect(delay: delay))
    }
}

// MARK: - Game Specific Animations
struct WinningLineAnimation: View {
    let isWinning: Bool
    let player: Player
    
    @State private var progress: Double = 0
    
    var body: some View {
        ZStack {
            if isWinning {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                player == .X ? Color(hex: "8B4513") : Color(hex: "708090"),
                                player == .X ? Color(hex: "A0522D") : Color(hex: "778899")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)
                    .scaleEffect(x: progress, anchor: .leading)
                    .opacity(0.8)
            }
        }
        .onAppear {
            if isWinning {
                withAnimation(.easeInOut(duration: 1.5)) {
                    progress = 1.0
                }
            }
        }
    }
}

struct CellPlacementAnimation: View {
    let player: Player
    @State private var scale: Double = 0
    @State private var rotation: Double = 180
    
    var body: some View {
        Text(player.symbol)
            .font(.system(size: 36, weight: .bold, design: .serif))
            .foregroundColor(player == .X ? Color(hex: "8B4513") : Color(hex: "708090"))
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.interpolatingSpring(
                    mass: 0.5,
                    stiffness: 200.0,
                    damping: 12.0,
                    initialVelocity: 5
                )) {
                    scale = 1.0
                    rotation = 0
                }
            }
    }
}

struct GameBoardTransition: ViewModifier {
    let isResetting: Bool
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isResetting ? 180 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .scaleEffect(isResetting ? 0.8 : 1.0)
            .opacity(isResetting ? 0.5 : 1.0)
            .animation(
                .easeInOut(duration: 0.8),
                value: isResetting
            )
    }
}

// MARK: - Menu Animations
struct MenuButtonHover: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .shadow(
                color: isHovered ? Color(hex: "8B4513").opacity(0.3) : Color.clear,
                radius: isHovered ? 8 : 0,
                x: 0,
                y: isHovered ? 4 : 0
            )
            .animation(
                .easeInOut(duration: 0.2),
                value: isHovered
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHovered = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isHovered = false
                    }
                }
            }
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    @State private var gradientOffset: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "F5F5DC"),
                Color(hex: "FAEBD7"),
                Color(hex: "F0E68C")  // Khaki
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .offset(y: gradientOffset)
        .animation(
            .easeInOut(duration: 4.0)
            .repeatForever(autoreverses: true),
            value: gradientOffset
        )
        .onAppear {
            gradientOffset = 50
        }
    }
}

// MARK: - Particle Effect for Wins
struct WinParticleView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            Particle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: UIScreen.main.bounds.height / 2
                ),
                color: [Color.yellow, Color.orange, Color.red].randomElement() ?? .yellow,
                size: CGFloat.random(in: 4...8),
                opacity: 1.0
            )
        }
        
        animateParticles()
    }
    
    private func animateParticles() {
        for index in particles.indices {
            withAnimation(
                .easeOut(duration: Double.random(in: 1.0...2.0))
                .delay(Double(index) * 0.1)
            ) {
                particles[index].position.y -= CGFloat.random(in: 100...200)
                particles[index].position.x += CGFloat.random(in: -50...50)
                particles[index].opacity = 0
            }
        }
    }
}

struct Particle {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}