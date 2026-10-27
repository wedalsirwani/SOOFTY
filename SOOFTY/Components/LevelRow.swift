import SwiftUI

struct LevelRow: View {
    let number: Int
    let title: String
    let subtitle: String
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 36) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 60, height: 60)
                        .shadow(
                            color: .black.opacity(0.10),
                            radius: 5,
                            x: 0,
                            y: 3
                        )

                    Image(
                        systemName: isUnlocked
                            ? "lock.open"
                            : "lock"
                    )
                    .font(.system(size: 21))
                    .foregroundStyle(
                        isUnlocked
                            ? Color.appBlue.opacity(0.75)
                            : Color.gray.opacity(0.55)
                    )
                }

                if number < 4 {
                    Rectangle()
                        .fill(Color.gray.opacity(0.65))
                        .frame(width: 1 , height: 22)
                }
            }
            .frame(width: 60)

            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        isUnlocked ? Color.appBlue : .black
                    )

                Text(subtitle)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(
                        isUnlocked
                            ? Color.appBlue.opacity(0.75)
                            : Color.gray
                    )
            }
            .frame(height: 60, alignment: .center)

            Spacer()
        }
        .frame(height: 93 , alignment: .top)
    }
}
