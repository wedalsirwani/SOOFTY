
import SwiftUI

struct AchievementsPage: View {

    @ObservedObject var gameProgress: GameProgress
    @Environment(\.dismiss) private var dismiss

    private let purple = Color(
        red: 0.37,
        green: 0.38,
        blue: 1.0
    )

    private let achievements: [
        (
            id: String,
            title: String,
            description: String,
            icon: String
        )
    ] = [

        (
            id: "first_game",
            title: "First Steps",
            description: "Complete your first game.",
            icon: "flag.fill"
        ),

        (
            id: "critical_thinker",
            title: "Critical Thinker",
            description: "Reach 85% Critical Thinking progress.",
            icon: "brain.head.profile"
        ),

        (
            id: "mastermind",
            title: "Mastermind",
            description: "Reach 100% Critical Thinking progress.",
            icon: "crown.fill"
        ),

        (
            id: "consistent_learner",
            title: "Consistent Learner",
            description: "Complete five games.",
            icon: "book.fill"
        ),

        (
            id: "three_day_streak",
            title: "Building a Habit",
            description: "Maintain a three-day streak.",
            icon: "flame.fill"
        ),

        (
            id: "seven_day_streak",
            title: "Week Warrior",
            description: "Maintain a seven-day streak.",
            icon: "calendar"
        ),

        (
            id: "thirty_day_streak",
            title: "Unstoppable",
            description: "Maintain a 30-day streak.",
            icon: "trophy.fill"
        )
    ]

    private var unlockedCount: Int {
        achievements.filter {
            gameProgress.isUnlocked($0.id)
        }.count
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Summary
                    VStack(alignment: .leading, spacing: 12) {

                        Text("Your Achievements")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundStyle(.primary)

                        Text(
                            "\(unlockedCount) of \(achievements.count) achievements unlocked"
                        )
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)

                        GeometryReader { geometry in

                            ZStack(alignment: .leading) {

                                Capsule()
                                    .fill(Color.gray.opacity(0.15))

                                Capsule()
                                    .fill(purple)
                                    .frame(
                                        width: geometry.size.width *
                                        CGFloat(unlockedCount) /
                                        CGFloat(achievements.count)
                                    )
                            }
                        }
                        .frame(height: 9)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(purple.opacity(0.08))
                    )

                    // MARK: - Streak Summary
                    StreakCard(gameProgress: gameProgress)

                    // MARK: - Achievement List
                    Text("All Achievements")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.primary)

                    VStack(spacing: 12) {

                        ForEach(achievements, id: \.id) { achievement in

                            achievementCard(
                                id: achievement.id,
                                title: achievement.title,
                                description: achievement.description,
                                icon: achievement.icon
                            )
                        }
                    }
                }
                .padding(22)
                .frame(maxWidth: 550)
                .frame(maxWidth: .infinity)
            }
            .background(Color.white)
            .navigationTitle("Achievements")
            .toolbar {

                ToolbarItem(placement: .automatic) {

                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(purple)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Achievement Card
    private func achievementCard(
        id: String,
        title: String,
        description: String,
        icon: String
    ) -> some View {

        let unlocked = gameProgress.isUnlocked(id)

        return HStack(spacing: 14) {

            ZStack {

                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        unlocked
                            ? Color.orange.opacity(0.13)
                            : Color.gray.opacity(0.10)
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: unlocked ? icon : "lock.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(
                        unlocked ? Color.orange : Color.gray
                    )
            }

            VStack(alignment: .leading, spacing: 5) {

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(unlocked ? "UNLOCKED" : "LOCKED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(
                        unlocked ? Color.green : Color.gray
                    )
                    .padding(.top, 3)
            }

            Spacer(minLength: 0)

            if unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.055))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    unlocked
                        ? Color.green.opacity(0.22)
                        : Color.gray.opacity(0.10),
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    AchievementsPage(
        gameProgress: GameProgress.shared
    )
}
