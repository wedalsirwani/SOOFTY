import SwiftUI

// MARK: - App Colors
extension Color {
    static let appBlue = Color(
        red: 62 / 255.0,
        green: 73 / 255.0,
        blue: 235 / 255.0
    )

    static let headerBlue = Color(
        red: 0.94,
        green: 0.94,
        blue: 1.0
    )
}

// MARK: - Custom Header
struct CustomHeader: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .top) {
            HeaderShape()
                .fill(Color.headerBlue)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 18) {
                    /*Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(width: 48, height: 48)
                            .background(.white.opacity(0.85))
                            .clipShape(Circle())
                    }*/

                    Text(title)
                        .font(.system(size: 18))
                        .foregroundStyle(.black)

                    Spacer()
                }
                .padding(.top, 75)

                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 30)

                Spacer()
            }
            .padding(.horizontal, 28)

            HeaderWaveLine()
                .stroke(Color.appBlue, lineWidth: 1)
        }
        .frame(height: 300)
    }
}

// MARK: - Header Background Shape
struct HeaderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - 10))

        path.addCurve(
            to: CGPoint(x: 0, y: rect.height - 50),
            control1: CGPoint(
                x: rect.width * 0.72,
                y: rect.height - 125
            ),
            control2: CGPoint(
                x: rect.width * 0.38,
                y: rect.height + 50
            )
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Header Wave Line
struct HeaderWaveLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(
            to: CGPoint(x: rect.width, y: rect.height - 25)
        )

        path.addCurve(
            to: CGPoint(x: 0, y: rect.height - 45),
            control1: CGPoint(
                x: rect.width * 0.72,
                y: rect.height - 125
            ),
            control2: CGPoint(
                x: rect.width * 0.38,
                y: rect.height + 50
            )
        )

        return path
    }
}

