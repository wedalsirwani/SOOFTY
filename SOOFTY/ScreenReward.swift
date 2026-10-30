
import SwiftUI

struct ScreenReward: View {

    // MARK: - Navigation

    @Environment(\.dismiss) private var dismiss

    var onKeepGrowing: (() -> Void)? = nil

    // MARK: - Design Colors

    private let purple = Color(
        red: 0.29,
        green: 0.30,
        blue: 0.96
    )

    private let backgroundBlue = Color(
        red: 245.0 / 255.0,
        green: 246.0 / 255.0,
        blue: 1.0
    )

    // MARK: - Animation State

    @State private var showConfetti = false
    @State private var showContent = false
    @State private var hasAppeared = false

    // MARK: - Main View

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // Background
                backgroundView(size: geometry.size)

                VStack(spacing: 0) {

                    // Header
                  
                    Spacer(minLength: 12)

                    // Celebration content
                    VStack(spacing: 0) {

                        Text("Well DONE!")
                            .font(
                                .system(
                                    size: 36,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(purple)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.bottom, 12)

                        // Soo fty
                        Image("soofty2")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(
                                    geometry.size.width * 0.78,
                                    340
                                ),
                                height: min(
                                    geometry.size.height * 0.39,
                                    300
                                )
                            )
                            .scaleEffect(
                                showContent ? 1.0 : 0.75
                            )
                            .opacity(
                                showContent ? 1.0 : 0.0
                            )

                        // Encouragement
                        VStack(spacing: 5) {

                            Text("You're doing Amazing")
                                .font(
                                    .system(
                                        size: 24,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(purple)
                                .multilineTextAlignment(.center)

                            Text("Keep going!")
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .light
                                    )
                                )
                                .foregroundStyle(purple.opacity(0.8))
                        }
                        .padding(.top, 18)
                        .opacity(showContent ? 1 : 0)
                        .offset(
                            y: showContent ? 0 : 12
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)

                    // Keep Growing button
                    Button {

                        // Stop confetti when leaving
                        showConfetti = false

                        if let onKeepGrowing {
                            onKeepGrowing()
                        } else {
                            dismiss()
                        }

                    } label: {

                        Text("Keep Growing")
                            .font(
                                .system(
                                    size: 17,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(purple)
                            .clipShape(Capsule())
                            .shadow(
                                color: purple.opacity(0.20),
                                radius: 18,
                                x: 0,
                                y: 8
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 34)
                    .padding(.bottom, 42)
                    .opacity(showContent ? 1 : 0)
                    .offset(
                        y: showContent ? 0 : 15
                    )
                }

                // Continuous Confetti
                if showConfetti {

                    RewardConfetti(
                        isActive: showConfetti
                    )
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .onAppear {

                guard !hasAppeared else {
                    return
                }

                hasAppeared = true

                withAnimation(
                    .spring(
                        response: 0.65,
                        dampingFraction: 0.78
                    )
                ) {
                    showContent = true
                }

                showConfetti = true
            }
        }
        .background(.white)
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.light)
    }

    // MARK: - Background Design

    // MARK: - Background Design

    private func backgroundView(size: CGSize) -> some View {

        ZStack(alignment: .bottom) {

            // Blue background fills the entire screen
            Color(
                red: 245.0 / 255.0,
                green: 246.0 / 255.0,
                blue: 1.0
            )

            // White top section
            Circle()
                .fill(Color.white)
                .frame(
                    width: size.width * 1.4,
                    height: size.width * 5
                )
                .position(
                    x: size.width / 2,
                    y: size.height * 0
                )
        }
        .frame(
            width: size.width,
            height: size.height
        )
    }
}

// MARK: - Continuous Confetti

private struct RewardConfetti: View {

    let isActive: Bool

    @State private var startDate = Date()

    private let particleCount = 65

    private let assetNames = [
        "blue",
        "green",
        "orange",
        "purple",
        "yellow"
    ]

    var body: some View {

        TimelineView(
            .animation(
                minimumInterval: 1.0 / 60.0,
                paused: !isActive
            )
        ) { timeline in

            GeometryReader { geometry in

                let elapsed = timeline.date
                    .timeIntervalSince(startDate)

                ZStack {

                    ForEach(
                        0..<particleCount,
                        id: \.self
                    ) { index in

                        RewardConfettiPiece(
                            index: index,
                            assetName: assetNames[
                                index % assetNames.count
                            ],
                            elapsed: elapsed,
                            screenSize: geometry.size
                        )
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }
        .onAppear {
            startDate = Date()
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Individual Confetti Piece

private struct RewardConfettiPiece: View {

    let index: Int
    let assetName: String
    let elapsed: Double
    let screenSize: CGSize

    private let fallDuration: Double = 4.5

    // Large pieces
    private var isLarge: Bool {
        index % 16 == 0
    }

    // Different starting delays
    private var startDelay: Double {
        Double(index % 20) * 0.13
    }

    // Continuous falling
    private var cycleProgress: CGFloat {

        let adjustedTime = elapsed + startDelay

        let progress = adjustedTime
            .truncatingRemainder(
                dividingBy: fallDuration
            ) / fallDuration

        return CGFloat(progress)
    }

    // Horizontal starting position
    private var startX: CGFloat {

        let fraction = CGFloat(
            (index * 47 + 13) % 100
        ) / 100

        return fraction * screenSize.width
    }

    // Gentle horizontal movement
    private var horizontalDrift: CGFloat {

        CGFloat((index % 7) - 3)
            * (isLarge ? 22 : 14)
    }

    // Large and small sizes
    private var pieceWidth: CGFloat {
        isLarge ? 204 : (index % 3 == 0 ? 13 : 16)
    }

    private var pieceHeight: CGFloat {
        isLarge ? 183.11 : (index % 3 == 0 ? 28 : 35)
    }

    // Travel completely beyond the screen
    private var verticalPosition: CGFloat {

        let travelDistance =
            screenSize.height + pieceHeight + 100

        return -pieceHeight
            + cycleProgress * travelDistance
    }

    var body: some View {

        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(
                width: pieceWidth,
                height: pieceHeight
            )
            .rotationEffect(
                .degrees(
                    Double(index * 37)
                    + Double(cycleProgress) * 360
                )
            )
            .position(
                x: startX
                    + horizontalDrift * cycleProgress,
                y: verticalPosition
            )
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {
        ScreenReward()
    }
}
