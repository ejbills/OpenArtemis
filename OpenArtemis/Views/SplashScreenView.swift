import SwiftUI
import FluidGradient

struct SplashScreenView: View {
    @Binding var isActive: Bool
    @State private var size = 0.3
    @State private var opacity = 0.0
    @State private var scale = 1.0
    @State private var yOffset: CGFloat = 0
    @State private var displayedText = ""
    private let fullText = "OpenArtemis"
    
    private let allColors: [Color] = [
        .red, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink
    ].shuffled()
    
    var body: some View {
        ZStack {
            Rectangle().fill(Material.ultraThin).opacity(opacity)
            
            FluidGradient(blobs: Array(allColors.prefix(2)),
                         highlights: Array(allColors.suffix(2)),
                         speed: 1.0,
                         blur: 0.75)
            .opacity(opacity * 0.35)
            
            VStack(spacing: 15) {
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .scaleEffect(size)
                    .opacity(opacity)
                
                Text(displayedText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .overlay {
                        FluidGradient(blobs: Array(allColors.prefix(3)),
                                    highlights: Array(allColors.suffix(3)),
                                    speed: 1.0,
                                    blur: 0.75)
                        .opacity(0.5)
                        .mask {
                            Text(displayedText)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                        }
                    }
                    .opacity(opacity)
            }
            .scaleEffect(scale)
            .offset(y: yOffset)
        }
        .ignoresSafeArea()
        .onAppear {
            // Initial fade in animation
            withAnimation(.easeOut(duration: 0.4)) {
                size = 1.0
                opacity = 1.0
            }
            
            // Start typing animation after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateText()
            }
            
            // Final scale and fade out animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeOut(duration: 0.3)) {
                    scale = 1.05
                    yOffset = -5
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isActive = false
                }
            }
        }
    }
    
    private func animateText() {
        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if charIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                withAnimation(.snappy(duration: 0.125)) { displayedText += String(fullText[index]) }
                charIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
