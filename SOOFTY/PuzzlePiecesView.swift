import SwiftUI
struct PuzzlePiecesView: View {

    var onPlacedCountChanged: (Int) -> Void = { _ in }

    // MARK: - Assets

    private let pieceNames = [
        "piece_r1_c1", "piece_r1_c2", "piece_r1_c3",
        "piece_r2_c1", "piece_r2_c2", "piece_r2_c3",
        "piece_r3_c1", "piece_r3_c2", "piece_r3_c3",
        "piece_r4_c1", "piece_r4_c2", "piece_r4_c3"
    ]

    // MARK: - Board

    private let boardWidth: CGFloat = 334
    private let boardHeight: CGFloat = 410

    private let puzzleWidth: CGFloat = 218.46
    private let puzzleHeight: CGFloat = 308.08

    // MARK: - Individual Piece Sizes

    private let pieceSizes: [CGSize] = [
        CGSize(width: 85.76, height: 90.95),
        CGSize(width: 86.54, height: 90.92),
        CGSize(width: 67.26, height: 91.30),

        CGSize(width: 84.26, height: 90.85),
        CGSize(width: 86.61, height: 92.04),
        CGSize(width: 67.16, height: 91.01),

        CGSize(width: 83.86, height: 74.73),
        CGSize(width: 86.65, height: 91.99),
        CGSize(width: 67.28, height: 93.16),

        CGSize(width: 66.70, height: 88.91),
        CGSize(width: 105.74, height: 70.95),
        CGSize(width: 67.10, height: 71.24)
    ]

    // MARK: - Assembly Settings

    private let extraHorizontalOverlap: CGFloat = 15
    private let extraVerticalOverlap: CGFloat = 10

    // MARK: - Row Measurements

    private var rowWidths: [CGFloat] {
        (0..<4).map { row in
            let start = row * 3

            return pieceSizes[start].width
                + pieceSizes[start + 1].width
                + pieceSizes[start + 2].width
        }
    }

    private var rowHeights: [CGFloat] {
        (0..<4).map { row in
            let start = row * 3

            return max(
                pieceSizes[start].height,
                max(
                    pieceSizes[start + 1].height,
                    pieceSizes[start + 2].height
                )
            )
        }
    }

    // MARK: - Overlap Calculations

    private var horizontalOverlap: [CGFloat] {
        rowWidths.map { width in
            max(
                0,
                (width - puzzleWidth) / 2
                    + extraHorizontalOverlap
            )
        }
    }

    private var verticalOverlap: CGFloat {
        let totalHeight = rowHeights.reduce(0, +)

        return max(
            0,
            (totalHeight - puzzleHeight) / 3
                + extraVerticalOverlap
        )
    }

    // MARK: - Assembled Dimensions

    private var assembledWidth: CGFloat {
        (0..<4).map { row in
            rowWidths[row] - 2 * horizontalOverlap[row]
        }.max() ?? puzzleWidth
    }

    private var assembledHeight: CGFloat {
        rowHeights.reduce(0, +)
            - verticalOverlap * 3
    }

    // MARK: - Centered Assembly Origin

    private var assemblyOrigin: CGPoint {
        CGPoint(
            x: (boardWidth - assembledWidth) / 2,
            y: (boardHeight - assembledHeight) / 2
        )
    }

    // MARK: - Starting Positions

    private let startingPositions: [CGPoint] = [
        CGPoint(x: 48, y: 145), // First piece moved down
        CGPoint(x: 150, y: 48),
        CGPoint(x: 282, y: 48),

        CGPoint(x: 55, y: 145),
        CGPoint(x: 160, y: 145),
        CGPoint(x: 280, y: 145),

        CGPoint(x: 48, y: 245),
        CGPoint(x: 155, y: 245),
        CGPoint(x: 282, y: 245),

        CGPoint(x: 48, y: 350),
        CGPoint(x: 165, y: 355),
        CGPoint(x: 282, y: 350)
    ]

    // MARK: - Game State

    @State private var positions: [CGPoint] = []
    @State private var placedPieces: Set<Int> = []
    @State private var dragOrigins: [Int: CGPoint] = [:]
    @State private var draggedIndex: Int? = nil

    // MARK: - Completion Animation State

    @State private var showCompletedImage = false
    @State private var showConfetti = false
    @State private var completionStarted = false

    private var isPuzzleComplete: Bool {
        placedPieces.count == pieceNames.count
    }

    // MARK: - Target Positions

    private var targetPositions: [CGPoint] {
        var targets = Array(
            repeating: CGPoint.zero,
            count: pieceNames.count
        )
        
        var rowTop = assemblyOrigin.y
        
        for row in 0..<4 {
            let first = row * 3
            let overlapX = horizontalOverlap[row]
            
            let actualRowWidth =
            rowWidths[row] - 2 * overlapX
            
            // Center each row horizontally.
            var pieceLeft =
            (boardWidth - actualRowWidth) / 2
            
            for column in 0..<3 {
                let index = first + column
                let size = pieceSizes[index]
                
                targets[index] = CGPoint(
                    x: pieceLeft + size.width / 2,
                    y: rowTop + size.height / 2
                )
                
                pieceLeft += size.width
                
                if column < 2 {
                    pieceLeft -= overlapX
                }
            }
            
            rowTop += rowHeights[row]
            
            if row < 3 {
                rowTop -= verticalOverlap
            }
        }
        // Fine-tune the bottom-left piece alignment.
        targets[9] = CGPoint(
            x: targets[9].x + 1,
            y: targets[9].y - 18
        )
        
        return targets
    }

    // MARK: - Main View

    var body: some View {
        ZStack {
            if showCompletedImage {
                completedPuzzle
                    .transition(
                        .opacity.combined(
                            with: .scale(scale: 0.88)
                        )
                    )
            } else {
                gameBoard
            }

            // Confetti falls over the completed picture.
            ConfettiCelebration(isActive: showConfetti)
                .frame(
                    width: boardWidth,
                    height: boardHeight
                )
                .allowsHitTesting(false)
                .zIndex(20)
        }
        .frame(
            width: boardWidth,
            height: boardHeight
        )
        .clipped()
        .onAppear {
            if positions.isEmpty {
                positions = startingPositions
            }
        }
        .onChange(of: placedPieces.count) { _, count in
            guard count == pieceNames.count,
                  !completionStarted else {
                return
            }

            completionStarted = true

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.5
            ) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showCompletedImage = true
                }

                showConfetti = true
            }
        }
    }

    // MARK: - Game Board

    private var gameBoard: some View {
        ZStack {
            // The transparent hint image is removed.

            if positions.count == pieceNames.count {
                ForEach(pieceNames.indices, id: \.self) { index in
                    puzzlePiece(at: index)
                }
            }
        }
        .frame(
            width: boardWidth,
            height: boardHeight
        )
    }

    // MARK: - Individual Puzzle Piece

    private func puzzlePiece(at index: Int) -> some View {
        Image(pieceNames[index])
            .resizable()
            .frame(
                width: pieceSizes[index].width,
                height: pieceSizes[index].height
            )
            .contentShape(Rectangle())
            .position(positions[index])
            .zIndex(
                draggedIndex == index ? 10 :
                    (placedPieces.contains(index) ? 0 : 1)
            )
            .gesture(dragGesture(for: index))
            .allowsHitTesting(
                !placedPieces.contains(index)
            )
            .accessibilityLabel(
                "Puzzle piece \(index + 1)"
            )
    }

    // MARK: - Completed Picture

    private var completedPuzzle: some View {
        Image("PuzzleOriginal")
            .resizable()
            .scaledToFit()
            .frame(
                width: assembledWidth,
                height: assembledHeight
            )
            .position(
                x: boardWidth / 2,
                y: boardHeight / 2
            )
            .accessibilityLabel("Completed original picture")
    }

    // MARK: - Drag and Snap

    private func dragGesture(
        for index: Int
    ) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !placedPieces.contains(index) else {
                    return
                }

                if dragOrigins[index] == nil {
                    dragOrigins[index] = positions[index]
                    draggedIndex = index
                }

                guard let origin = dragOrigins[index] else {
                    return
                }

                let halfWidth = pieceSizes[index].width / 2
                let halfHeight = pieceSizes[index].height / 2

                let newX = origin.x + value.translation.width
                let newY = origin.y + value.translation.height

                positions[index] = CGPoint(
                    x: min(
                        max(newX, halfWidth),
                        boardWidth - halfWidth
                    ),
                    y: min(
                        max(newY, halfHeight),
                        boardHeight - halfHeight
                    )
                )
            }
            .onEnded { _ in
                guard !placedPieces.contains(index) else {
                    dragOrigins[index] = nil
                    draggedIndex = nil
                    return
                }

                guard let origin = dragOrigins[index] else {
                    draggedIndex = nil
                    return
                }

                let target = targetPositions[index]
                let current = positions[index]

                let distance = hypot(
                    current.x - target.x,
                    current.y - target.y
                )

                let snapDistance: CGFloat = 38

                if distance < snapDistance {
                    withAnimation(.spring(response: 0.25)) {
                        positions[index] = target
                        placedPieces.insert(index)
                    }

                    onPlacedCountChanged(placedPieces.count)
                } else {
                    withAnimation(.spring(response: 0.25)) {
                        positions[index] = origin
                    }
                }

                dragOrigins[index] = nil
                draggedIndex = nil
            }
    }
}

// MARK: - Confetti Celebration

private struct ConfettiCelebration: View {

    let isActive: Bool

    private let particleCount = 42

    private let colors: [Color] = [
        Color(red: 0.29, green: 0.30, blue: 0.96),
        Color(red: 0.71, green: 0.87, blue: 0.55),
        Color(red: 1.00, green: 0.73, blue: 0.42),
        Color(red: 0.96, green: 0.55, blue: 0.68),
        Color(red: 0.56, green: 0.79, blue: 0.96),
        Color(red: 0.78, green: 0.67, blue: 0.96)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { index in
                    particle(
                        index: index,
                        size: geometry.size
                    )
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipped()
        }
        .opacity(isActive ? 1 : 0)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func particle(
        index: Int,
        size: CGSize
    ) -> some View {
        let startX =
            CGFloat((index * 47 + 13) % 100)
            / 100 * size.width

        let endX =
            startX + CGFloat((index % 7) - 3) * 17

        let endY =
            size.height + CGFloat(index % 6) * 24

        let delay = Double(index % 12) * 0.055

        let width: CGFloat = index % 3 == 0 ? 6 : 9
        let height: CGFloat = index % 3 == 0 ? 12 : 7

        Capsule()
            .fill(colors[index % colors.count])
            .frame(width: width, height: height)
            .rotationEffect(
                .degrees(
                    isActive
                        ? Double(index * 97 % 360)
                        : 0
                )
            )
            .position(
                x: isActive ? endX : startX,
                y: isActive ? endY : -20
            )
            .animation(
                .easeIn(duration: 1.45)
                    .delay(delay),
                value: isActive
            )
    }
}

// MARK: - Preview

#Preview {
    PuzzlePiecesView()
        .background(.white)
}
