
import SwiftUI

struct StreakCard: View {

    @ObservedObject var gameProgress: GameProgress

    var body: some View {

        HStack(spacing: 16) {

            Image(systemName: "flame.fill")
                .font(.system(size: 34))
                .foregroundStyle(
                    Color(
                        red: 0.96,
                        green: 0.49,
                        blue: 0.15
                    )
                )

            VStack(alignment: .leading, spacing: 5) {

                Text("\(gameProgress.currentStreak)-Day Streak")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)

                Text(
                    gameProgress.currentStreak == 1
                        ? "You've started your streak!"
                        : "Keep your daily learning streak alive."
                )
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

                Text(
                    "Longest streak: \(gameProgress.longestStreak) days"
                )
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.orange.opacity(0.10))
        )
    }
}
