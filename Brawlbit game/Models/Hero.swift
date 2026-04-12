import SwiftData
import Foundation

@Model
final class Hero {
    var name: String
    var heroClass: HeroClass
    var battleground: Battleground
    var activeSkin: String
    var points: Int
    var coins: Int = 0
    var shieldOrbs: Int = 0
    var createdAt: Date
    var hp: Double   // 0.0–1.0, persists across the session
    /// Raw values of HeroClass cases the user owns (starts with the chosen one)
    var unlockedHeroClasses: [String] = []
    /// Raw values of Battleground cases the user owns (starts with the chosen one)
    var unlockedBattlegrounds: [String] = []
    /// true = easy (revenges count as victories), false = hard (missed deadline = defeat)
    var easyMode: Bool = true
    /// End date of an active vacation (inclusive). nil = no vacation active.
    var vacationEndDate: Date? = nil

    static let heroCost = 500
    static let arenaCost = 200

    init(name: String, heroClass: HeroClass, battleground: Battleground) {
        self.name = name
        self.heroClass = heroClass
        self.battleground = battleground
        self.activeSkin = "default"
        self.points = 0
        self.coins = 0
        self.createdAt = Date()
        self.hp = 1.0
        self.unlockedHeroClasses = [heroClass.rawValue]
        self.unlockedBattlegrounds = [battleground.rawValue]
    }
}

enum HeroClass: String, Codable, CaseIterable {
    case knight, mage, rogue

    var displayName: String {
        switch self {
        case .knight: return "Knight"
        case .mage: return "Mage"
        case .rogue: return "Rogue"
        }
    }

    var emoji: String {
        switch self {
        case .knight: return "🛡️"
        case .mage: return "🔮"
        case .rogue: return "🗡️"
        }
    }

    var assetPrefix: String {
        switch self {
        case .knight: return "Knight"
        case .mage: return "Mage"
        case .rogue: return "Rogue"
        }
    }

    var roomAssetName: String {
        switch self {
        case .knight: return "knight room"
        case .mage:   return "Mage room"
        case .rogue:  return "Roge room"
        }
    }

    var previewAsset: String {
        switch self {
        case .knight: return "Knight/Knight/knight"
        case .mage: return "Mage/Mage/mage"
        case .rogue: return "Rogue/Rogue/rogue"
        }
    }

    var idleFrames: [String] {
        switch self {
        case .knight: return (1...12).map { "Knight/Knight/Idle/idle\($0)" }
        case .mage:   return (1...14).map { "Mage/Mage/Idle/idle\($0)" }
        case .rogue:  return (1...18).map { "Rogue/Rogue/Idle/idle\($0)" }
        }
    }

    var attackFrames: [String] {
        switch self {
        case .knight: return (1...4).map { "Knight/Knight/Attack/attack\($0)" }
        case .mage:   return (1...7).map { "Mage/Mage/Attack/attack\($0)" }
        case .rogue:  return (1...7).map { "Rogue/Rogue/Attack/Attack\($0)" }
        }
    }

    // Scene display calibration (height + vertical offset)
    var sceneHeight: CGFloat {
        switch self {
        case .knight: return 120
        case .mage:   return 120
        case .rogue:  return 120
        }
    }

    var sceneYOffset: CGFloat {
        switch self {
        case .knight: return 6
        case .mage:   return 6
        case .rogue:  return 6
        }
    }

    var walkFrames: [String] {
        switch self {
        case .knight: return (1...6).map { "Knight/Knight/Walk/walk\($0)" }
        case .mage:   return (1...6).map { "Mage/Mage/Walk/walk\($0)" }
        case .rogue:  return (1...6).map { "Rogue/Rogue/Walk/walk\($0)" }
        }
    }

    var runFrames: [String] {
        switch self {
        case .knight: return (1...8).map { "Knight/Knight/Run/run\($0)" }
        case .mage:   return (1...8).map { "Mage/Mage/Run/run\($0)" }
        case .rogue:  return (1...8).map { "Rogue/Rogue/Run/run\($0)" }
        }
    }

    // Todos los sets de ataque disponibles (para elegir uno aleatorio)
    var allAttackSets: [[String]] {
        switch self {
        case .knight: return [
            (1...4).map { "Knight/Knight/Attack/attack\($0)" },
            (1...8).map { "Knight/Knight/Extra_Attack/attack_extra\($0)" }
        ]
        case .mage: return [
            (1...7).map { "Mage/Mage/Attack/attack\($0)" }
        ]
        case .rogue: return [
            (1...7).map { "Rogue/Rogue/Attack/Attack\($0)" },
            (1...11).map { "Rogue/Rogue/Extra_Attack/attack_extra\($0)" }
        ]
        }
    }

    // Non-combat ambient animation (jump)
    var jumpFrames: [String] {
        switch self {
        case .knight: return (1...7).map { "Knight/Knight/Jump/jump\($0)" }
        case .mage:   return (1...7).map { "Mage/Mage/Jump/jump\($0)" }
        case .rogue:  return (1...7).map { "Rogue/Rogue/Jump/jump\($0)" }
        }
    }

    var highJumpFrames: [String] {
        switch self {
        case .knight: return ["Knight/Knight/Jump_high/jump1"] + (2...12).map { "Knight/Knight/Jump_high/high_jump\($0)" }
        case .mage:   return (1...12).map { "Mage/Mage/High_jump/high_jump\($0)" }
        case .rogue:  return (1...12).map { "Rogue/Rogue/High_Jump/high_jump\($0)" }
        }
    }
}

enum Battleground: String, Codable, CaseIterable {
    case beach, city, egypt, forest, mountains, snow

    var displayName: String {
        switch self {
        case .beach:     return "Beach"
        case .city:      return "City"
        case .egypt:     return "Egypt"
        case .forest:    return "Forest"
        case .mountains: return "Mountains"
        case .snow:      return "Snow"
        }
    }

    var assetName: String {
        switch self {
        case .beach:     return "Battlegrounds/Battleground/beach"
        case .city:      return "Battlegrounds/Battleground/city"
        case .egypt:     return "Battlegrounds/Battleground/Egipt"
        case .forest:    return "Battlegrounds/Battleground/forest"
        case .mountains: return "Battlegrounds/Battleground/mountains"
        case .snow:      return "Battlegrounds/Battleground/snow"
        }
    }

    // How far from the bottom of the scene the characters stand (matches ground line in image)
    var groundPadding: CGFloat {
        switch self {
        case .beach:     return 48
        case .city:      return 48
        case .egypt:     return 68
        case .forest:    return 68
        case .mountains: return 68
        case .snow:      return 68
        }
    }
}
