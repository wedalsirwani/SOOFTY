
import SwiftUI
import Combine

struct PuzzleGameView: View {

    // MARK: - Navigation

    @Environment(\.dismiss) private var dismiss

    let onGameCompleted: ((Double) -> Void)?

    @State private var showRewardScreen = false

    init(onGameCompleted: ((Double) -> Void)? = nil) {
        self.onGameCompleted = onGameCompleted
    }

    // MARK: - Design

    private let purple = Color(red: 0.29, green: 0.30, blue: 0.96)
    private let lightPurple = Color(red: 0.96, green: 0.96, blue: 1.0)

    private let totalTime = 60
    private let totalPieces = 12

    // MARK: - Game State

    @State private var remainingSeconds = 60
    @State private var isPaused = false
    @State private var isFinished = false
    @State private var placedPieces = 0
    @State private var puzzleResetID = 0
    @State private var resultSubmitted = false
    @State private var showConfetti = false

    // MARK: - Timer

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    private var timeProgress: CGFloat {
        CGFloat(max(remainingSeconds, 0)) / CGFloat(totalTime)
    }

    private var formattedTime: String {
        String(
            format: "%02d:%02d",
            remainingSeconds / 60,
            remainingSeconds % 60
        )
    }

    private var timerColor: Color {
        if remainingSeconds <= 10 {
            return .red
        } else if remainingSeconds <= 20 {
            return .orange
        } else {
            return purple
        }
    }

    private var isTimeRunningLow: Bool {
        remainingSeconds <= 10
    }

    // MARK: - Earned Progress

    private var earnedProgress: Double {
        placedPieces == totalPieces && remainingSeconds > 0
            ? 0.15
            : 0
    }

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 0) {

            headerView

            controlsView

            progressView

            puzzleView

            Spacer(minLength: 20)

            finishButton
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(.white)
        .ignoresSafeArea(edges: .bottom)

        // MARK: - Confetti

        .overlay {

            if showConfetti {

                PuzzleConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .zIndex(5)
            }
        }

        // MARK: - Pause Overlay

        .overlay {

            if isPaused && !isFinished {

                overlayPanel {

                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(purple)

                    Text("Game Paused")
                        .font(.system(size: 23, weight: .semibold))

                    Text("Take a breath. Your progress is safe.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Resume") {

                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPaused = false
                        }
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 13)
                    .background(purple)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                }
                .zIndex(10)
            }
        }

        // MARK: - Completion Overlay

        .overlay {

            if isFinished {

                overlayPanel {

                    Image(
                        systemName: remainingSeconds == 0
                            ? "clock.badge.exclamationmark"
                            : "checkmark.seal.fill"
                    )
                    .font(.system(size: 52))
                    .foregroundStyle(purple)

                    Text(
                        remainingSeconds == 0
                            ? "Time's Up!"
                            : "Game Completed!"
                    )
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.black)

                    Text(
                        remainingSeconds == 0
                            ? "Your time is up. Keep practicing!"
                            : "Amazing! You completed the puzzle!"
                    )
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                    Text("\(placedPieces)/\(totalPieces) pieces completed")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)

                    if earnedProgress > 0 {

                        Text("+15% skill progress")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(purple)

                    } else {

                        Text("Keep practicing to earn progress!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(purple)
                    }

                    // MARK: - Continue to Reward

                    Button {

                        guard !resultSubmitted else {
                            return
                        }

                        resultSubmitted = true

                        // Update GameProgress in MainPage2r.
                        onGameCompleted?(earnedProgress)

                        if earnedProgress > 0 {

                            // Open the shared reward screen.
                            showConfetti = false
                            showRewardScreen = true

                        } else {

                            // No reward for unsuccessful attempts.
                            dismiss()
                        }

                    } label: {

                        Text(
                            earnedProgress > 0
                                ? "Continue"
                                : "Keep Growing"
                        )
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(purple)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 5)
                }
                .zIndex(10)
            }
        }

        // MARK: - Countdown Timer

        .onReceive(timer) { _ in

            guard !isPaused && !isFinished else {
                return
            }

            if remainingSeconds > 0 {

                remainingSeconds -= 1

                if remainingSeconds == 0 {

                    withAnimation(.spring()) {
                        isFinished = true
                    }
                }
            }
        }

        // MARK: - Reward Screen Presentation

        .fullScreenCover(isPresented: $showRewardScreen) {

            ScreenReward(

                onKeepGrowing: {

                    // Close reward screen.
                    showRewardScreen = false

                    // Return to MainPage2r.
                    dismiss()
                }
            )
        }

        .preferredColorScheme(.light)
    }

    // MARK: - Header

    private var headerView: some View {

        HStack(spacing: 30) {

            Button {

                dismiss()

            } label: {

                Image(systemName: "chevron.left")
                    .font(.system(size: 27, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 58, height: 58)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(
                        color: .black.opacity(0.055),
                        radius: 15,
                        x: 0,
                        y: 6
                    )
            }
            .disabled(isFinished)
            .accessibilityLabel("Back")

            Text("Time Management")
                .font(.system(size: 18))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 27)
        .padding(.top, 12)
    }

    // MARK: - Instructions and Controls

    private var controlsView: some View {

        HStack(spacing: 12) {

            Text("Piece it together!")
                .font(.system(size: 16))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            // Pause / Resume

            Button {

                isPaused.toggle()

            } label: {

                Image(
                    systemName: isPaused ? "play.fill" : "pause"
                )
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(purple)
                .frame(width: 54, height: 54)
                .background(.white)
                .clipShape(Circle())
                .shadow(
                    color: .black.opacity(0.045),
                    radius: 13,
                    x: 0,
                    y: 5
                )
            }
            .disabled(isFinished)
            .accessibilityLabel(
                isPaused ? "Resume game" : "Pause game"
            )

            // Restart

            Button {

                restartGame()

            } label: {

                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(purple)
                    .frame(width: 54, height: 54)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(
                        color: .black.opacity(0.045),
                        radius: 13,
                        x: 0,
                        y: 5
                    )
            }
            .disabled(resultSubmitted || isFinished)
            .accessibilityLabel("Restart game")
        }
        .padding(.horizontal, 27)
        .padding(.top, 42)
    }

    // MARK: - Progress and Countdown

    private var progressView: some View {

        HStack(spacing: 12) {

            Text("\(placedPieces)/\(totalPieces)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.gray.opacity(0.9))
                .monospacedDigit()

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(
                            Color(
                                red: 0.91,
                                green: 0.91,
                                blue: 1.0
                            )
                        )

                    Capsule()
                        .fill(timerColor)
                        .frame(
                            width: geometry.size.width * timeProgress
                        )
                        .animation(
                            .linear(duration: 1),
                            value: remainingSeconds
                        )
                }
            }
            .frame(height: 9)

            HStack(spacing: 5) {

                Text(formattedTime)
                    .font(
                        .system(
                            size: 15,
                            weight: isTimeRunningLow ? .bold : .regular
                        )
                    )
                    .monospacedDigit()

                Image(systemName: "clock")
                    .font(.system(size: 16))
            }
            .foregroundStyle(timerColor)
            .fixedSize()
        }
        .padding(.horizontal, 28)
        .padding(.top, 46)
    }

    // MARK: - Puzzle Area

    private var puzzleView: some View {

        PuzzlePiecesView { count in

            guard !isPaused && !isFinished else {
                return
            }

            placedPieces = min(count, totalPieces)

            // Start confetti when all pieces are placed.

            if placedPieces == totalPieces && !showConfetti {

                withAnimation(.easeInOut(duration: 0.25)) {
                    showConfetti = true
                }
            }
        }
        .id(puzzleResetID)
        .frame(width: 334, height: 410)
        .overlay {

            Rectangle()
                .stroke(
                    Color.indigo.opacity(0.15),
                    lineWidth: 1
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .allowsHitTesting(!isPaused && !isFinished)
    }

    // MARK: - Finish Button

    private var finishButton: some View {

        Button {

            finishGame()

        } label: {

            Text("Finish")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(purple)
                .clipShape(Capsule())
        }
        .disabled(
            placedPieces != totalPieces ||
            isPaused ||
            isFinished
        )
        .opacity(placedPieces == totalPieces ? 1 : 0.5)
        .padding(.horizontal, 34)
        .padding(.bottom, 76)
    }

    // MARK: - Finish Game

    private func finishGame() {

        guard placedPieces == totalPieces,
              remainingSeconds > 0,
              !isPaused,
              !isFinished else {
            return
        }

        withAnimation(
            .spring(response: 0.5, dampingFraction: 0.8)
        ) {

            isFinished = true
            showConfetti = true
        }
    }

    // MARK: - Reusable Overlay

    private func overlayPanel<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {

        ZStack {

            Color.black.opacity(0.22)
                .ignoresSafeArea()

            VStack(spacing: 16, content: content)
                .padding(28)
                .frame(maxWidth: 330)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(radius: 25)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Restart

    private func restartGame() {

        guard !resultSubmitted && !isFinished else {
            return
        }

        withAnimation(.easeInOut(duration: 0.25)) {

            remainingSeconds = totalTime
            isPaused = false
            isFinished = false
            placedPieces = 0
            showConfetti = false

            puzzleResetID += 1
        }
    }
}

// MARK: - Puzzle Confetti Animation

private struct PuzzleConfettiView: View {

    private let colors: [Color] = [
        .purple,
        .green,
        .pink,
        .orange,
        .yellow,
        .blue,
        .cyan
    ]

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                ForEach(0..<65, id: \.self) { index in

                    PuzzleConfettiPiece(
                        index: index,
                        screenHeight: geometry.size.height,
                        screenWidth: geometry.size.width,
                        color: colors[index % colors.count]
                    )
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Individual Confetti Piece

private struct PuzzleConfettiPiece: View {

    let index: Int
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    let color: Color

    @State private var isFalling = false

    private var xPosition: CGFloat {

        let fraction = CGFloat(
            (index * 47 + 13) % 100
        ) / 100

        return fraction * screenWidth
    }

    private var fallDuration: Double {
        2.2 + Double(index % 12) * 0.12
    }

    private var startDelay: Double {
        Double(index % 20) * 0.045
    }

    var body: some View {

        Group {

            if index.isMultiple(of: 3) {

                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)

            } else {

                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(
                        width: index.isMultiple(of: 2) ? 7 : 5,
                        height: index.isMultiple(of: 2) ? 12 : 8
                    )
                    .rotationEffect(
                        .degrees(isFalling ? 260 : 0)
                    )
            }
        }
        .position(
            x: xPosition,
            y: isFalling ? screenHeight + 60 : -20
        )
        .opacity(isFalling ? 0.9 : 1)
        .animation(
            .linear(duration: fallDuration)
                .repeatForever(autoreverses: false)
                .delay(startDelay),
            value: isFalling
        )
        .onAppear {
            isFalling = true
        }
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {
        PuzzleGameView()
    }
}
