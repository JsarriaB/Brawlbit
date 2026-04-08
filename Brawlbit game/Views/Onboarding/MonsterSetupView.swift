import SwiftUI
import SwiftData

// MARK: - Supporting types (file-scope)

private struct PendingTask: Identifiable {
    let id = UUID()
    var taskName: String
    var monsterType: MonsterType
    var hour: Int
    var minute: Int
    var routineIndex: Int
}

private struct AddTaskConfig: Identifiable {
    let id = UUID()
    let routineIndex: Int
}

// MARK: - Main View

struct MonsterSetupView: View {
    @Environment(\.modelContext) private var modelContext

    let heroName: String
    let heroClass: HeroClass
    let battleground: Battleground
    let easyMode: Bool
    let onContinue: () -> Void

    @State private var pendingTasks: [PendingTask] = []
    @State private var routine1Days: Set<Int> = Set(0...6)  // default: all days
    @State private var routine2Days: Set<Int> = []
    @State private var showRoutine2 = false
    @State private var addTaskConfig: AddTaskConfig? = nil

    @AppStorage("routine1Name") private var routine1Name = "WEEKDAYS"
    @AppStorage("routine2Name") private var routine2Name = "WEEKEND"

    private var routine1Tasks: [PendingTask] { pendingTasks.filter { $0.routineIndex == 0 } }
    private var routine2Tasks: [PendingTask] { pendingTasks.filter { $0.routineIndex == 1 } }

    private var canContinue: Bool {
        !routine1Tasks.isEmpty && !routine1Days.isEmpty
    }

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📋 Your routines")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Up to 2 routines on different days of the week.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(white: 0.45))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 52)
                    .padding(.bottom, 28)

                    // Routine 1
                    RoutineSectionView(
                        label: "ROUTINE 1",
                        name: $routine1Name,
                        tasks: routine1Tasks,
                        selectedDays: routine1Days,
                        blockedDays: showRoutine2 ? routine2Days : [],
                        canAddMore: routine1Tasks.count < 7,
                        onDayTap: { toggleDay($0, inRoutine: 0) },
                        onAddTap: { addTaskConfig = AddTaskConfig(routineIndex: 0) },
                        onRemove: { id in pendingTasks.removeAll { $0.id == id } }
                    )

                    if showRoutine2 {
                        Rectangle()
                            .fill(Color(white: 1, opacity: 0.07))
                            .frame(height: 1)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 24)

                        RoutineSectionView(
                            label: "ROUTINE 2",
                            name: $routine2Name,
                            tasks: routine2Tasks,
                            selectedDays: routine2Days,
                            blockedDays: routine1Days,
                            canAddMore: routine2Tasks.count < 7,
                            onDayTap: { toggleDay($0, inRoutine: 1) },
                            onAddTap: { addTaskConfig = AddTaskConfig(routineIndex: 1) },
                            onRemove: { id in pendingTasks.removeAll { $0.id == id } }
                        )
                    } else {
                        Button {
                            // Pre-fill routine 2 with days NOT already in routine 1
                            routine2Days = Set(0...6).subtracting(routine1Days)
                            showRoutine2 = true
                        } label: {
                            Label("Add routine 2", systemImage: "plus.circle")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                    }

                    OnboardingCTAButton(
                        title: "Let's battle! ⚔️",
                        isEnabled: canContinue,
                        action: saveTasks
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 48)
                }
            }
        }
        .sheet(item: $addTaskConfig) { config in
            AddTaskSheet(
                existingTaskNames: pendingTasks
                    .filter { $0.routineIndex == config.routineIndex }
                    .map { $0.taskName }
            ) { taskName, monsterType, hour, minute in
                pendingTasks.append(PendingTask(
                    taskName: taskName, monsterType: monsterType,
                    hour: hour, minute: minute,
                    routineIndex: config.routineIndex
                ))
                addTaskConfig = nil
            }
        }
    }

    // Toggle a day in a routine; routine 1 takes priority over routine 2.
    private func toggleDay(_ day: Int, inRoutine routineIndex: Int) {
        if routineIndex == 0 {
            if routine1Days.contains(day) {
                routine1Days.remove(day)
            } else {
                routine1Days.insert(day)
                routine2Days.remove(day)   // routine 1 reclaims this day
            }
        } else {
            guard !routine1Days.contains(day) else { return }
            if routine2Days.contains(day) { routine2Days.remove(day) }
            else { routine2Days.insert(day) }
        }
    }

    private func saveTasks() {
        let hero = Hero(name: heroName, heroClass: heroClass, battleground: battleground)
        hero.easyMode = easyMode
        modelContext.insert(hero)

        var insertedTasks: [MonsterTask] = []
        for (index, task) in pendingTasks.enumerated() {
            let days = task.routineIndex == 0 ? Array(routine1Days) : Array(routine2Days)
            let monsterTask = MonsterTask(
                taskName: task.taskName,
                monsterType: task.monsterType,
                deadlineHour: task.hour,
                deadlineMinute: task.minute,
                order: index,
                routineIndex: task.routineIndex,
                daysOfWeek: days
            )
            modelContext.insert(monsterTask)
            insertedTasks.append(monsterTask)
        }

        try? modelContext.save()
        NotificationService.scheduleAll(tasks: insertedTasks)
        onContinue()
    }
}

// MARK: - Routine Section

private struct RoutineSectionView: View {
    let label: String
    @Binding var name: String
    let tasks: [PendingTask]
    let selectedDays: Set<Int>
    let blockedDays: Set<Int>
    let canAddMore: Bool
    let onDayTap: (Int) -> Void
    let onAddTap: () -> Void
    let onRemove: (UUID) -> Void

    private let dayLetters = ["M", "Tu", "W", "Th", "F", "Sa", "Su"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.orange)
                    .tracking(1)
                TextField("Routine name", text: $name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .tint(.orange)
            }

            // Day picker
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { i in
                    let isSelected = selectedDays.contains(i)
                    let isBlocked = blockedDays.contains(i)
                    Button { onDayTap(i) } label: {
                        Text(dayLetters[i])
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 40, height: 40)
                            .background(
                                isSelected ? Color.orange :
                                isBlocked  ? Color(white: 0.1) :
                                             Color(white: 0.14)
                            )
                            .foregroundColor(
                                isSelected ? .white :
                                isBlocked  ? Color(white: 0.22) :
                                             Color(white: 0.5)
                            )
                            .clipShape(Circle())
                    }
                    .disabled(isBlocked)
                }
            }

            // Task list
            if !tasks.isEmpty {
                VStack(spacing: 0) {
                    ForEach(tasks) { task in
                        HStack(spacing: 12) {
                            Text(task.taskName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%02d:%02d", task.hour, task.minute))
                                .font(.system(size: 12))
                                .foregroundColor(Color(white: 0.4))
                            Text("·")
                                .foregroundColor(Color(white: 0.25))
                            Text(task.monsterType.displayName)
                                .font(.system(size: 12))
                                .foregroundColor(Color(white: 0.4))
                            Button { onRemove(task.id) } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color(white: 0.45))
                                    .padding(7)
                                    .background(Color(white: 1, opacity: 0.08))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.vertical, 8)

                        Rectangle()
                            .fill(Color(white: 1, opacity: 0.05))
                            .frame(height: 1)
                    }
                }
            }

            // Add task button
            if canAddMore {
                Button(action: onAddTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Add task")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(Color(white: 0.5))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(white: 1, opacity: 0.06))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// AddTaskSheet and AnimatedMonsterCard are defined in Views/Shared/
