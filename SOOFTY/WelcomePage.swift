
import SwiftUI

struct WelcomePage: View {

    @State private var appear = false
    @State private var pulse = false
    @State private var navigateToHome = false

    var body: some View {

        NavigationStack {

            ZStack {

                gradientBackground

                centerContent

                cornerDecoration
            }
            .onAppear(perform: startAnimations)
            .navigationDestination(isPresented: $navigateToHome) {
                MainPage2r()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Pieces of the screen

    private var gradientBackground: some View {

        LinearGradient(
            colors: [
                Color(hex: "F5F6FF"),
                Color(hex: "E4E8FF")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var centerContent: some View {

        VStack(spacing: 16) {

            Image("LOGO1")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(logoScale)
                .opacity(appear ? 1 : 0)

            Text("Learn, Play, Grow!")
                .font(.system(size: 18, weight: .medium))
                .italic()
                .foregroundColor(Color(hex: "616AFF"))
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
        }
    }

    private var cornerDecoration: some View {

        GeometryReader { geo in

            Image("Group2")
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.7)
                .offset(x: 94, y: 80)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomTrailing
                )
        }
        .ignoresSafeArea()
    }

    // MARK: - Animation Logic

    private var logoScale: CGFloat {

        guard appear else {
            return 0.5
        }

        return pulse ? 1.05 : 1.0
    }

    private func startAnimations() {

        // Show logo and text

        withAnimation(
            .spring(response: 0.8, dampingFraction: 0.6)
        ) {
            appear = true
        }

        // Start logo pulse

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

            guard !navigateToHome else { return }

            withAnimation(
                .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                pulse = true
            }
        }

        // Navigate to the home page after 3 seconds

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {

            withAnimation(.easeInOut(duration: 0.5)) {
                navigateToHome = true
            }
        }
    }
}

// MARK: - Color Extension

extension Color {

    init(hex: String) {

        let scanner = Scanner(string: hex)

        _ = scanner.scanString("#")

        var rgb: UInt64 = 0

        _ = scanner.scanHexInt64(&rgb)

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

// MARK: - Preview

#Preview {

    WelcomePage()
}
