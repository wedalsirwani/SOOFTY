
import SwiftUI
import Combine

final class GameProgress: ObservableObject {

    static let shared = GameProgress()

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current
    private let dataVersionKey = "gameProgressDataVersion"

    // MARK: - Skill Progress

    @Published private(set) var timeProgress: Double = 0.0
    @Published private(set) var thinkingProgress: Double = 0.0
    @Published private(set) var memoryProgress: Double = 0.0

    // MARK: - Game Statistics

    @Published private(set) var completedGames: Int = 0

    // MARK: - Streak

    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0
    @Published private(set) var lastPlayedDate: Date?

    // MARK: - Achievements

    @Published private(set) var unlockedAchievements: Set<String> = []

    private init() {

        if defaults.integer(forKey: dataVersionKey) < 2 {
            resetSavedData()
            defaults.set(2, forKey: dataVersionKey)
        }

        loadData()
        refreshStreak()
        checkAchievements()
        saveData()
    }

    // MARK: - Overall Progress

    var overallProgress: Double {
        (
            timeProgress +
            thinkingProgress +
            memoryProgress
        ) / 3.0
    }

    // MARK: - Complete Critical Thinking Game

    func completeCriticalThinkingGame(earnedProgress: Double) {

        guard earnedProgress > 0 else {
            return
        }

        thinkingProgress = min(
            thinkingProgress + earnedProgress,
            1.0
        )

        completedGames += 1

        recordPlayToday()
        checkAchievements()
        saveData()
    }
    // MARK: - Complete Time Management Game

    func completeTimeManagementGame(earnedProgress: Double) {

        guard earnedProgress > 0 else {
            return
        }

        timeProgress = min(
            timeProgress + earnedProgress,
            1.0
        )

        completedGames += 1

        recordPlayToday()
        checkAchievements()
        saveData()

        print("Time Management Progress: \(timeProgress * 100)%")
    }

    // MARK: - Daily Streak

    private func recordPlayToday() {

        let today = calendar.startOfDay(for: Date())

        if let lastPlayedDate = lastPlayedDate {

            let previousDay = calendar.startOfDay(
                for: lastPlayedDate
            )

            if calendar.isDate(previousDay, inSameDayAs: today) {
                return
            }

            let daysBetween = calendar.dateComponents(
                [.day],
                from: previousDay,
                to: today
            ).day ?? 0

            currentStreak = daysBetween == 1
                ? currentStreak + 1
                : 1

        } else {
            currentStreak = 1
        }

        self.lastPlayedDate = today

        longestStreak = max(
            longestStreak,
            currentStreak
        )
    }

    private func refreshStreak() {

        guard let lastPlayedDate = lastPlayedDate else {
            currentStreak = 0
            return
        }

        let today = calendar.startOfDay(for: Date())

        let previousDay = calendar.startOfDay(
            for: lastPlayedDate
        )

        let daysBetween = calendar.dateComponents(
            [.day],
            from: previousDay,
            to: today
        ).day ?? 0

        if daysBetween < 0 || daysBetween > 1 {
            currentStreak = 0
        }
    }

    // MARK: - Achievements

    private func checkAchievements() {

        if completedGames >= 1 {
            unlockedAchievements.insert("first_game")
        }

        if thinkingProgress >= 0.85 {
            unlockedAchievements.insert("critical_thinker")
        }

        if thinkingProgress >= 1.0 {
            unlockedAchievements.insert("mastermind")
        }

        if completedGames >= 5 {
            unlockedAchievements.insert("consistent_learner")
        }

        if currentStreak >= 3 {
            unlockedAchievements.insert("three_day_streak")
        }

        if currentStreak >= 7 {
            unlockedAchievements.insert("seven_day_streak")
        }

        if currentStreak >= 30 {
            unlockedAchievements.insert("thirty_day_streak")
        }
    }

    func isUnlocked(_ id: String) -> Bool {
        unlockedAchievements.contains(id)
    }

    // MARK: - Save Data

    private func saveData() {

        defaults.set(timeProgress, forKey: "timeProgress")
        defaults.set(thinkingProgress, forKey: "thinkingProgress")
        defaults.set(memoryProgress, forKey: "memoryProgress")

        defaults.set(completedGames, forKey: "completedGames")

        defaults.set(currentStreak, forKey: "currentStreak")
        defaults.set(longestStreak, forKey: "longestStreak")

        defaults.set(lastPlayedDate, forKey: "lastPlayedDate")

        defaults.set(
            Array(unlockedAchievements),
            forKey: "unlockedAchievements"
        )
    }

    // MARK: - Load Data

    private func loadData() {

        timeProgress = defaults.double(forKey: "timeProgress")
        thinkingProgress = defaults.double(forKey: "thinkingProgress")
        memoryProgress = defaults.double(forKey: "memoryProgress")

        completedGames = defaults.integer(forKey: "completedGames")

        currentStreak = defaults.integer(forKey: "currentStreak")
        longestStreak = defaults.integer(forKey: "longestStreak")

        lastPlayedDate = defaults.object(
            forKey: "lastPlayedDate"
        ) as? Date

        unlockedAchievements = Set(
            defaults.stringArray(
                forKey: "unlockedAchievements"
            ) ?? []
        )
    }

    // MARK: - Reset Saved Data

    private func resetSavedData() {

        let keys = [
            "timeProgress",
            "thinkingProgress",
            "memoryProgress",
            "completedGames",
            "currentStreak",
            "longestStreak",
            "lastPlayedDate",
            "unlockedAchievements"
        ]

        for key in keys {
            defaults.removeObject(forKey: key)
        }

        timeProgress = 0
        thinkingProgress = 0
        memoryProgress = 0

        completedGames = 0

        currentStreak = 0
        longestStreak = 0

        lastPlayedDate = nil
        unlockedAchievements = []
    }
}
