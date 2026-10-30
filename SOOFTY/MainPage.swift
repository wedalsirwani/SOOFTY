//
//  Main.swift
//  SOOFTY
//
//  Created by Reema Mohammed Abdulaziz Alzannan on 11/05/1448 AH.
//


import SwiftUI

struct MainPage: View {
    @State private var score = 0
    @State private var selectedSkill = ""
    @State private var showAlert = false
    
    private let purple = Color(
        red: 0.37, green: 0.38, blue: 1.0
    )
    
    var body: some View {
        GeometryReader { geometry in
            
            let screenHeight = geometry.size.height
            let cardHeight = min(max(screenHeight * 0.115, 100), 100)
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    CustomHeader(
                        title: "",
                        subtitle: ""
                    )
                    .ignoresSafeArea(edges: .top)
                    
                }
                // MARK: Main Content

                ScrollView(showsIndicators: false) {

                    VStack(alignment: .leading, spacing: 0) {

                        // Score

                        HStack(spacing: 8) {
                            Spacer()

                            Image(systemName: "flame.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(
                                    Color(red: 0.96, green: 0.49, blue: 0.15)
                                )

                            Text("\(score)")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(Color(
                                    red: 21.0 / 255.0,
                                    green: 34.0 / 255.0,
                                    blue: 246.0 / 255.0

)
)
                            
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 24)

                        // Progress Card

                        ZStack(alignment: .topLeading) {

                            RoundedRectangle(cornerRadius: 34)
                                .fill(purple)

                            VStack(alignment: .leading, spacing: 12) {

                                Text("Progress")
                                    .font(.system(size: 23, weight: .medium))
                                    .foregroundStyle(.white)

                                Text(
                                    "Your progress will appear here as you play and improve your skills."
                                )
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.white.opacity(0.95))
                                .lineSpacing(4)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                            }
                            .padding(.horizontal, 23)
                            .padding(.top, 48)
                        }
                        .frame(height: min(screenHeight * 0.245, 205))
                        .overlay(alignment: .topLeading) {

                            Image("SOOFTY")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 82, height: 82)
                                .offset(x: 24, y: -68)
                        }
                        .padding(.top, 43)
                        .padding(.horizontal,29)

                        // Skills Heading

                        Text("Skills Cards")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(
                                Color(
                                    red: 21.0 / 255.0,
                                    green: 34.0 / 255.0,
                                    blue: 246.0 / 255.0
                                )
                            )
                            .padding(.horizontal, 39)
                            .padding(.top, 35)
                            .padding(.bottom, 18)

                        //* Glossy Skill Cards

                        VStack(spacing: 14) {

                            glossyCard(
                                title: "Memory Cards",
                                icon: "brain",
                                colors: [
                                    Color(red: 0.57, green: 0.57, blue: 1.0),
                                    Color(red: 0.47, green: 0.47, blue: 0.96)
                                ],
                                height: cardHeight
                            )

                            glossyCard(
                                title: "Critical Thinking",
                                icon: "asterisk",
                                colors: [
                                    Color(red: 0.97, green: 0.56, blue: 0.23),
                                    Color(red: 0.91, green: 0.45, blue: 0.13)
                                ],
                                height: cardHeight
                            )

                            glossyCard(
                                title: "Time Management",
                                icon: "clock",
                                colors: [
                                    Color(red: 0.76, green: 0.91, blue: 0.61),
                                    Color(red: 0.66, green: 0.85, blue: 0.46)
                                ],
                                height: cardHeight
                            )
                        }
                        .padding(.horizontal, 29)
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: 500)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarBackButtonHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert("Let's play!", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You selected \(selectedSkill).")
        }
    }
    

    // MARK: Glossy Card Component

    private func glossyCard(
        title: String,
        icon: String,
        colors: [Color],
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
            .background {

                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Fine glossy border

            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.65),
                                .white.opacity(0.08),
                                .white.opacity(0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                    .allowsHitTesting(false)
            }

            // Soft shadow

            .shadow(
                color: colors[1].opacity(0.22),
                radius: 9,
                x: 0,
                y: 5
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: Background Wave

struct WaveShape: Shape {

    func path(in rect: CGRect) -> Path {

        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))

        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height),
            control1: CGPoint(
                x: rect.width * 0.35,
                y: rect.height * 0.75
            ),
            control2: CGPoint(
                x: rect.width * 0.70,
                y: rect.height * 0.10
            )
        )

        return path
    }

}
#Preview {
    MainPage()
}
