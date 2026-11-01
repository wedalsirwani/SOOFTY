
import SwiftUI
import Combine

struct MemoryGameScreen: View {

    // MARK: - Navigation

    @Environment(\.dismiss) private var dismiss

    var onGameCompleted: ((Double) -> Void)? = nil

    @State private var showRewardScreen = false

    // MARK: - Design

    private let appBlue = Color(
        red: 62 / 255.0,
        green: 73 / 255.0,
        blue: 235 / 255.0
    )

    // MARK: - Game Settings

    private let totalTime = 60
    private let memorizeTime = 5

    // MARK: - Cards

    // Numbers are shuffled once when the game starts.
    // Their positions never change during the game.

    @State private var cards = [4, 1, 7, 2, 9, 3, 6, 8, 5]

    // Cards that the user has correctly opened.
    @State private var revealedCards: Set<Int> = []

    // Card that is temporarily showing because it was wrong.
    @State private var wrongCard: Int? = nil

    // The next number the user needs to find.
    @State private var nextNumber = 1

    // MARK: - Timer State

    @State private var remainingSeconds = 60
    @State private var memorizeSeconds = 5

    @State private var isMemorizing = true
    @State private var isPaused = false
    @State private var isFinished = false

    @State private var isSuccess = false
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

    private var earnedProgress: Double {
        isSuccess ? 0.15 : 0
    }

    // MARK: - Main View

    var body: some View {

        VStack(spacing: 0) {

            // MARK: Header

            HStack(spacing: 18) {

                Button {
                    dismiss()
                } label: {

                    Image(systemName: "chevron.left")
                        .font(.system(size: 22))
                        .foregroundStyle(.black)
                        .frame(width: 48, height: 48)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(
                            color: .black.opacity(0.08),
                            radius: 8
                        )
                }
                .buttonStyle(.plain)

                Text("Memory Cards")
                    .font(.system(size: 18))
                    .foregroundStyle(.black)

                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 15)

            // MARK: Game Title and Controls

            HStack(spacing: 12) {

                Text(
                    isMemorizing
                    ? "Memorize the numbers!"
                    : "Find the numbers in order!"
                )
                .font(.system(size: 16))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Spacer(minLength: 5)

                Button {
                    isPaused.toggle()
                } label: {

                    Image(
                        systemName: isPaused
                        ? "play.fill"
                        : "pause"
                    )
                    .font(.system(size: 20))
                    .foregroundStyle(appBlue)
                    .frame(width: 48, height: 48)
                    .background(.white)
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(isFinished)

                Button {
                    restartGame()
                } label: {

                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20))
                        .foregroundStyle(appBlue)
                        .frame(width: 48, height: 48)
                        .background(.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(resultSubmitted)
            }
            .padding(.horizontal, 27)
            .padding(.top, 35)

            // MARK: Timer

            HStack(spacing: 12) {

                Text("\(nextNumber)/9")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)

                GeometryReader { geometry in

                    ZStack(alignment: .leading) {

                        Capsule()
                            .fill(appBlue.opacity(0.12))

                        Capsule()
                            .fill(
                                remainingSeconds <= 10
                                ? .red
                                : appBlue
                            )
                            .frame(
                                width: geometry.size.width * timeProgress
                            )
                    }
                }
                .frame(height: 7)

                Text(formattedTime)
                    .font(.system(size: 14))
                    .monospacedDigit()
                    .foregroundStyle(
                        remainingSeconds <= 10
                        ? .red
                        : .gray
                    )

                Image(systemName: "clock")
                    .foregroundStyle(
                        remainingSeconds <= 10
                        ? .red
                        : .gray
                    )
            }
            .padding(.horizontal, 35)
            .padding(.top, 40)

            // MARK: Instructions

            if isMemorizing && !isFinished {

                Text("Remember the location of each number!")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.top, 22)

                Text("\(memorizeSeconds)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(appBlue)
                    .padding(.top, 5)

            } else if !isFinished {

                Text("Find number \(nextNumber)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(appBlue)
                    .padding(.top, 25)
            }

            // MARK: Number Cards

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 20),
                    count: 3
                ),
                spacing: 24
            ) {

                ForEach(cards.indices, id: \.self) { index in

                    let isVisible =
                        isMemorizing ||
                        revealedCards.contains(index) ||
                        wrongCard == index

                    Button {

                        selectCard(index)

                    } label: {

                        ZStack {

                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)

                            Text(isVisible ? "\(cards[index])" : "")
                                .font(
                                    .system(
                                        size: 20,
                                        weight: .medium
                                    )
                                )
                                .foregroundStyle(.black)

                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    revealedCards.contains(index)
                                    ? .appBlue
                                    : (
                                        wrongCard == index
                                        ? .red
                                        : Color.gray.opacity(0.15)
                                    ),
                                    lineWidth: 2
                                )
                        }
                        .frame(height: 90)
                        .shadow(
                            color: .black.opacity(0.08),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                        .rotation3DEffect(
                            .degrees(isVisible ? 0 : 180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(
                            .easeInOut(duration: 0.35),
                            value: isVisible
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        isMemorizing ||
                        isPaused ||
                        isFinished ||
                        revealedCards.contains(index) ||
                        wrongCard != nil
                    )
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 35)

            Spacer(minLength: 20)

            // MARK: Finish Button

            Button {
                finishGame()
            } label: {

                Text("Finish")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(appBlue)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(
                isMemorizing ||
                isPaused ||
                isFinished
            )
            .opacity(
                isMemorizing || isPaused || isFinished
                ? 0.6
                : 1
            )
            .padding(.horizontal, 34)
            .padding(.bottom, 55)
        }
        .background(.white)
        .navigationBarBackButtonHidden(true)

        // MARK: Confetti

        .overlay {

            if showConfetti {

                MemoryConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .zIndex(5)
            }
        }

        // MARK: Pause Overlay

        .overlay {

            if isPaused && !isFinished {

                overlayPanel {

                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(appBlue)

                    Text("Game Paused")
                        .font(.system(size: 23, weight: .semibold))

                    Text("Take a breath. Your progress is safe.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                    Button("Resume") {
                        isPaused = false
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 13)
                    .background(appBlue)
                    .clipShape(Capsule())
                }
                .zIndex(10)
            }
        }

        // MARK: Completion Overlay

        .overlay {

            if isFinished {

                overlayPanel {

                    Image(
                        systemName: isSuccess
                        ? "checkmark.seal.fill"
                        : "clock.badge.exclamationmark"
                    )
                    .font(.system(size: 52))
                    .foregroundStyle(appBlue)

                    Text(
                        isSuccess
                        ? "Amazing Work!"
                        : "Time's Up!"
                    )
                    .font(.system(size: 25, weight: .bold))

                    Text(
                        isSuccess
                        ? "You found all the numbers in the correct order!"
                        : "You ran out of time. Keep practicing!"
                    )
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                    Text(
                        "+\(Int((earnedProgress * 100).rounded()))% skill progress"
                    )
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(appBlue)

                    Button {

                        guard !resultSubmitted else {
                            return
                        }

                        resultSubmitted = true

                        onGameCompleted?(earnedProgress)

                        if isSuccess {

                            showConfetti = false
                            showRewardScreen = true

                        } else {

                            dismiss()
                        }

                    } label: {

                        Text(
                            isSuccess
                            ? "Continue"
                            : "Return to Progress"
                        )
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(appBlue)
                        .clipShape(Capsule())
                    }
                    .padding(.top, 5)
                }
                .zIndex(10)
            }
        }

        // MARK: Timer Logic

        .onReceive(timer) { _ in

            guard !isPaused && !isFinished else {
                return
            }

            if isMemorizing {

                if memorizeSeconds > 0 {
                    memorizeSeconds -= 1
                }

                if memorizeSeconds == 0 {
                    isMemorizing = false
                }

            } else {

                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                }

                if remainingSeconds == 0 {
                    finishGame()
                }
            }
        }

        // MARK: Reward Screen

        .fullScreenCover(isPresented: $showRewardScreen) {

            ScreenReward(
                onKeepGrowing: {

                    showRewardScreen = false
                    dismiss()
                }
            )
        }

        .preferredColorScheme(.light)
    }

    // MARK: - Select Card

    private func selectCard(_ index: Int) {

        guard !isMemorizing,
              !isPaused,
              !isFinished,
              !revealedCards.contains(index),
              wrongCard == nil else {
            return
        }

        // Check whether the selected number is correct.

        if cards[index] == nextNumber {

            // Correct: keep the card open permanently.

            withAnimation(.easeInOut(duration: 0.35)) {

                revealedCards.insert(index)
                nextNumber += 1
            }

            // All nine numbers found!

            if nextNumber == 10 {
                finishGame()
            }

        } else {

            // Wrong: show the number temporarily.

            withAnimation(.easeInOut(duration: 0.35)) {
                wrongCard = index
            }

            // Flip it back after one second.

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1
            ) {

                guard !isFinished else {
                    return
                }

                withAnimation(.easeInOut(duration: 0.35)) {
                    wrongCard = nil
                }
            }
        }
    }

    // MARK: - Finish Game

    private func finishGame() {

        guard !isFinished else {
            return
        }

        isSuccess = nextNumber == 10
        isFinished = true

        if isSuccess {

            withAnimation(.easeInOut(duration: 0.25)) {
                showConfetti = true
            }
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

    // MARK: - Restart Game

    private func restartGame() {

        guard !resultSubmitted else {
            return
        }

        // Shuffle the cards again for a new game.

        cards = Array(1...9).shuffled()

        revealedCards.removeAll()
        wrongCard = nil

        nextNumber = 1

        remainingSeconds = totalTime
        memorizeSeconds = 5

        isMemorizing = true
        isPaused = false
        isFinished = false
        isSuccess = false
        showConfetti = false
    }
}

// MARK: - Memory Confetti

private struct MemoryConfettiView: View {

    private let colors: [Color] = [
        .purple, .green, .pink, .orange, .yellow, .blue, .cyan
    ]

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                ForEach(0..<65, id: \.self) { index in

                    MemoryConfettiPiece(
                        index: index,
                        screenHeight: geometry.size.height,
                        screenWidth: geometry.size.width,
                        color: colors[index % colors.count]
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Individual Confetti Piece

private struct MemoryConfettiPiece: View {

    let index: Int
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    let color: Color

    @State private var isFalling = false

    private var xPosition: CGFloat {
        CGFloat((index * 47 + 13) % 100) / 100 * screenWidth
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
                    .frame(width: 7, height: 10)
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
            .linear(
                duration: 2.5 + Double(index % 10) * 0.12
            )
            .repeatForever(autoreverses: false)
            .delay(Double(index % 20) * 0.045),
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
        MemoryGameScreen()
    }
}
