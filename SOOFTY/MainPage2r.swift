import SwiftUI

struct MainPage2r: View {

    // MARK: - Navigation

    @State private var showTimeManagementGame = false
    @State private var showCriticalThinkingGame = false
    @State private var showAchievements = false

    // MARK: - Shared Progress

    @StateObject private var gameProgress = GameProgress.shared

    @State private var score = 0
    @State private var selectedSkill = ""
    @State private var showAlert = false

    // MARK: - Colors

    private let purple = Color(
        red: 0.37,
        green: 0.38,
        blue: 1.0
    )

    private let timeColor = Color(
        red: 0.72,
        green: 0.76,
        blue: 1.0
    )

    private let thinkingColor = Color(
        red: 0.97,
        green: 0.56,
        blue: 0.23
    )

    private let memoryColor = Color(
        red: 0.76,
        green: 0.91,
        blue: 0.61
    )

    // MARK: - Main Page

    var body: some View {

        GeometryReader { geometry in

            let screenHeight = geometry.size.height
            let cardHeight: CGFloat = 100

            ZStack(alignment: .top) {

                CustomHeader(
                    title: "",
                    subtitle: ""
                )
                .ignoresSafeArea(edges: .top)

                ScrollView(showsIndicators: false) {

                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: - Score and Streak

                        HStack(spacing: 8) {

                            Spacer()

                            Image(systemName: "flame.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(
                                    Color(
                                        red: 0.96,
                                        green: 0.49,
                                        blue: 0.15
                                    )
                                )

                            Text("\(gameProgress.currentStreak)")
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    Color(
                                        red: 21.0 / 255.0,
                                        green: 34.0 / 255.0,
                                        blue: 246.0 / 255.0
                                    )
                                )
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 24)

                        // MARK: - Progress Card

                        ZStack(alignment: .topLeading) {

                            RoundedRectangle(cornerRadius: 34)
                                .fill(purple)

                            HStack(
                                alignment: .center,
                                spacing: 8
                            ) {

                                VStack(
                                    alignment: .leading,
                                    spacing: 12
                                ) {

                                    Text("Progress")
                                        .font(
                                            .system(
                                                size: 23,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundStyle(.white)

                                    VStack(
                                        alignment: .leading,
                                        spacing: 7
                                    ) {

                                        progressLegend(
                                            title: "Time Management",
                                            color: timeColor
                                        )

                                        progressLegend(
                                            title: "Critical Thinking",
                                            color: thinkingColor
                                        )

                                        progressLegend(
                                            title: "Memory Cards",
                                            color: memoryColor
                                        )
                                    }
                                }

                                Spacer(minLength: 0)

                                // Circular Progress Chart

                                ZStack {

                                    progressRing(
                                        progress: gameProgress.timeProgress,
                                        diameter: 100,
                                        lineWidth: 7,
                                        color: timeColor
                                    )

                                    progressRing(
                                        progress: gameProgress.thinkingProgress,
                                        diameter: 80,
                                        lineWidth: 7,
                                        color: thinkingColor
                                    )

                                    progressRing(
                                        progress: gameProgress.memoryProgress,
                                        diameter: 60,
                                        lineWidth: 7,
                                        color: memoryColor
                                    )

                                    VStack(spacing: 2) {

                                        Text(
                                            "\(Int((gameProgress.overallProgress * 100).rounded()))%"
                                        )
                                        .font(
                                            .system(
                                                size: 17,
                                                weight: .bold
                                            )
                                        )
                                        .foregroundStyle(.white)
                                        .contentTransition(.numericText())
                                        .animation(
                                            .easeInOut(duration: 0.5),
                                            value: gameProgress.overallProgress
                                        )

                                        Text("Overall")
                                            .font(
                                                .system(
                                                    size: 10,
                                                    weight: .medium
                                                )
                                            )
                                            .foregroundStyle(
                                                .white.opacity(0.85)
                                            )
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 35)
                        }
                        .frame(
                            height: min(
                                screenHeight * 0.245,
                                205
                            )
                        )
                        .overlay(alignment: .topLeading) {

                            Image("SOOFTY")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 82, height: 82)
                                .offset(x: 24, y: -68)
                        }
                        .padding(.top, 43)
                        .padding(.horizontal, 29)

                        // MARK: - Daily Streak Card

                        StreakCard(gameProgress: gameProgress)
                            .padding(.horizontal, 29)
                            .padding(.top, 20)

                        // MARK: - Achievements Button

                        Button {

                            showAchievements = true

                        } label: {

                            HStack(spacing: 12) {

                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 22))

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text("Achievements")
                                        .font(
                                            .system(
                                                size: 17,
                                                weight: .semibold
                                            )
                                        )

                                    Text(
                                        "\(gameProgress.unlockedAchievements.count) unlocked"
                                    )
                                    .font(.system(size: 13))
                                    .opacity(0.85)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(
                                        .system(
                                            size: 14,
                                            weight: .semibold
                                        )
                                    )
                            }
                            .foregroundStyle(purple)
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(purple.opacity(0.08))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 29)
                        .padding(.top, 14)

                        // MARK: - Skills Heading

                        Text("Skills Cards")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(
                                Color(
                                    red: 21.0 / 255.0,
                                    green: 34.0 / 255.0,
                                    blue: 246.0 / 255.0
                                )
                            )
                            .padding(.horizontal, 39)
                            .padding(.top, 30)
                            .padding(.bottom, 18)

                        // MARK: - Skill Cards

                        VStack(spacing: 14) {

                            // Memory Cards

                            skillCard(
                                title: "Memory Cards",
                                icon: "brain",
                                color: Color(
                                    red: 0.57,
                                    green: 0.57,
                                    blue: 1.0
                                ),
                                height: cardHeight
                            )

                            // Critical Thinking

                            Button {

                                showCriticalThinkingGame = true

                            } label: {

                                HStack(spacing: 15) {

                                    Image(systemName: "asterisk")
                                        .font(
                                            .system(
                                                size: 26,
                                                weight: .medium
                                            )
                                        )
                                        .frame(width: 32)

                                    Text("Critical Thinking")
                                        .font(
                                            .system(
                                                size: 19,
                                                weight: .medium
                                            )
                                        )
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)

                                    Spacer(minLength: 0)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 22)
                                .frame(maxWidth: .infinity)
                                .frame(height: cardHeight)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(thinkingColor)
                                )
                            }
                            .buttonStyle(.plain)

                            // Time Management

                            Button {

                                showTimeManagementGame = true

                            } label: {

                                HStack(spacing: 15) {

                                    Image(systemName: "clock")
                                        .font(
                                            .system(
                                                size: 26,
                                                weight: .medium
                                            )
                                        )
                                        .frame(width: 32)

                                    Text("Time Management")
                                        .font(
                                            .system(
                                                size: 19,
                                                weight: .medium
                                            )
                                        )
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)

                                    Spacer(minLength: 0)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 22)
                                .frame(maxWidth: .infinity)
                                .frame(height: cardHeight)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(
                                            Color(
                                                red: 182.0 / 255.0,
                                                green: 223.0 / 255.0,
                                                blue: 141.0 / 255.0
                                            )
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 29)
                        .padding(.bottom, 25)
                    }
                    .frame(maxWidth: 500)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .navigationBarBackButtonHidden(true)
        }

        // MARK: - Present Critical Thinking Game

        .sheet(isPresented: $showCriticalThinkingGame) {

            CriticalThinkingGamePage(
                onGameCompleted: { earnedProgress in

                    print(
                        "Critical Thinking earned: \(earnedProgress)"
                    )

                    gameProgress.completeCriticalThinkingGame(
                        earnedProgress: earnedProgress
                    )

                    print(
                        "Updated Critical Thinking: \(gameProgress.thinkingProgress * 100)%"
                    )
                }
            )
        }

        // MARK: - Present Time Management Puzzle

        .fullScreenCover(isPresented: $showTimeManagementGame) {

            PuzzleGameView(
                onGameCompleted: { earnedProgress in

                    print("Time Management earned: \(earnedProgress)")

                    // Update the shared GameProgress instance directly.
                    GameProgress.shared.completeTimeManagementGame(
                        earnedProgress: earnedProgress
                    )

                    print(
                        "Updated Time Management: \(GameProgress.shared.timeProgress * 100)%"
                    )

                    print(
                        "Updated Overall Progress: \(GameProgress.shared.overallProgress * 100)%"
                    )
                }
            )
        }

        // MARK: - Present Achievements

        .sheet(isPresented: $showAchievements) {

            AchievementsPage(
                gameProgress: gameProgress
            )
        }

        // MARK: - Skill Alert

        .alert(
            "Let's play!",
            isPresented: $showAlert
        ) {

            Button("OK", role: .cancel) { }

        } message: {

            Text("You selected \(selectedSkill).")
        }
    }

    // MARK: - Progress Ring

    private func progressRing(
        progress: Double,
        diameter: CGFloat,
        lineWidth: CGFloat,
        color: Color
    ) -> some View {

        ZStack {

            Circle()
                .stroke(
                    Color.white.opacity(0.28),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )

            Circle()
                .trim(
                    from: 0,
                    to: CGFloat(min(max(progress, 0), 1))
                )
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: diameter, height: diameter)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8),
            value: progress
        )
    }

    // MARK: - Progress Legend

    private func progressLegend(
        title: String,
        color: Color
    ) -> some View {

        HStack(spacing: 8) {

            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(height: 24, alignment: .leading)
    }

    // MARK: - Skill Card

    private func skillCard(
        title: String,
        icon: String,
        color: Color,
        height: CGFloat
    ) -> some View {

        Button {

            selectedSkill = title
            showAlert = true

        } label: {

            HStack(spacing: 15) {

                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .frame(width: 32)

                Text(title)
                    .font(.system(size: 19, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 0)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(color)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {
        MainPage2r()
    }
}
