import SwiftData
import Foundation

@Model
final class Goal90 {
    var goalText: String
    var startDate: Date
    var daysCompleted: Int
    var isCompleted: Bool = false
    var completedAt: Date? = nil

    init(goalText: String) {
        self.goalText = goalText
        self.startDate = Date()
        self.daysCompleted = 0
    }

    var progressPercentage: Double {
        min(Double(daysCompleted) / 90.0, 1.0)
    }

    var daysRemaining: Int {
        max(0, 90 - daysCompleted)
    }
}
