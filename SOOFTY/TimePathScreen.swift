import SwiftUI

struct TimePathScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                CustomHeader(
                    title: "Game Path",
                    subtitle: "Beat the clock! Solve the puzzle before time runs out!"
                )

                VStack(spacing: 0) {
                    LevelRow(
                        number: 1,
                        title: "Level 1",
                        subtitle: "Beginner",
                        isUnlocked: true
                    )

                    LevelRow(
                        number: 2,
                        title: "Level 2",
                        subtitle: "Explorer",
                        isUnlocked: false
                    )

                    LevelRow(
                        number: 3,
                        title: "Level 3",
                        subtitle: "Challenger",
                        isUnlocked: false
                    )

                    LevelRow(
                        number: 4,
                        title: "Level 4",
                        subtitle: "Master",
                        isUnlocked: false
                    )
                }
                .padding(.horizontal, 52)
                .padding(.top, 30)

                Spacer(minLength: 20)

                Button(action: {}) {
                    Text("Start")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.appBlue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 34)
                .padding(.bottom, 76)
            }
            .background(.white)
            .ignoresSafeArea(edges: .top)

        }
    }
}

#Preview {
    TimePathScreen()
}
