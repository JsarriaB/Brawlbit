import Foundation

struct MonsterTemplate: Identifiable {
    let id = UUID()
    let taskName: String
    let monsterType: MonsterType
}

struct MonsterCatalog {
    static let predefined: [MonsterTemplate] = [
        MonsterTemplate(taskName: "Make the bed", monsterType: .demon),
        MonsterTemplate(taskName: "Brush teeth", monsterType: .lizard),
        MonsterTemplate(taskName: "Go to the gym", monsterType: .dragon),
        MonsterTemplate(taskName: "Wake up early", monsterType: .jinn),
        MonsterTemplate(taskName: "Drink water", monsterType: .lizard),
        MonsterTemplate(taskName: "Eat healthy", monsterType: .smallDragon),
        MonsterTemplate(taskName: "Study / work", monsterType: .medusa),
        MonsterTemplate(taskName: "No phone in bed", monsterType: .demon),
        MonsterTemplate(taskName: "Meditate", monsterType: .jinn),
        MonsterTemplate(taskName: "Read 10 pages", monsterType: .lizard),
        MonsterTemplate(taskName: "Take a walk", monsterType: .smallDragon),
        MonsterTemplate(taskName: "Sleep on time", monsterType: .medusa),
        MonsterTemplate(taskName: "Cold shower", monsterType: .dragon),
        MonsterTemplate(taskName: "Journal", monsterType: .demon),
        MonsterTemplate(taskName: "Tidy up", monsterType: .lizard),
    ]
}
