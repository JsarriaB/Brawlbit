import SwiftUI
import SwiftData

struct RoutinesSettingsView: View {
    @Query(sort: \MonsterTask.order) private var tasks: [MonsterTask]
    @Environment(\.modelContext) private var modelContext

    @State private var editingTask: MonsterTask? = nil
    @State private var showAddTask: AddTaskTarget? = nil

    private var routine1Tasks: [MonsterTask] { tasks.filter { $0.routineIndex == 0 } }
    private var routine2Tasks: [MonsterTask] { tasks.filter { $0.routineIndex == 1 } }
    private var hasTwoRoutines: Bool { !routine2Tasks.isEmpty }
    private var routine1Days: Set<Int> { Set(routine1Tasks.flatMap { $0.daysOfWeek }) }
    private var routine2Days: Set<Int> { Set(routine2Tasks.flatMap { $0.daysOfWeek }) }

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    routineBlock(label: "ROUTINE 1", tasks: routine1Tasks, days: routine1Days, routineIndex: 0)

                    if hasTwoRoutines {
                        divider()
                        routineBlock(label: "ROUTINE 2", tasks: routine2Tasks, days: routine2Days, routineIndex: 1)

                        Button(role: .destructive) {
                            for task in routine2Tasks { modelContext.delete(task) }
                            try? modelContext.save()
                            NotificationService.scheduleAll(tasks: routine1Tasks)
                        } label: {
                            Label("Remove Routine 2", systemImage: "trash")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    } else {
                        Button {
                            let available = Array(Set(0...6).subtracting(routine1Days))
                            showAddTask = AddTaskTarget(routineIndex: 1, availableDays: available)
                        } label: {
                            Label("Add Routine 2", systemImage: "plus.circle")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("Routines")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $editingTask) { task in
            let otherDays: Set<Int> = task.routineIndex == 0 ? routine2Days : routine1Days
            EditTaskSheet(task: task, blockedDays: otherDays)
        }
        .sheet(item: $showAddTask) { target in
            let existingNames = tasks
                .filter { $0.routineIndex == target.routineIndex }
                .map { $0.taskName }
            AddTaskSheet(existingTaskNames: existingNames) { taskName, monsterType, hour, minute in
                let days = target.availableDays.isEmpty ? Array(0...6) : target.availableDays
                let newTask = MonsterTask(
                    taskName: taskName,
                    monsterType: monsterType,
                    deadlineHour: hour,
                    deadlineMinute: minute,
                    order: tasks.count,
                    routineIndex: target.routineIndex,
                    daysOfWeek: days
                )
                modelContext.insert(newTask)
                try? modelContext.save()
                NotificationService.scheduleAll(tasks: tasks)
                showAddTask = nil
            }
        }
    }

    // MARK: - Routine block

    @ViewBuilder
    private func routineBlock(label: String, tasks: [MonsterTask], days: Set<Int>, routineIndex: Int) -> some View {
        let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]

        VStack(alignment: .leading, spacing: 14) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .tracking(1)
                .padding(.horizontal, 24)

            // Day pills
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { i in
                    Text(dayLetters[i])
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 38, height: 38)
                        .background(days.contains(i) ? Color.orange : Color(white: 0.14))
                        .foregroundColor(days.contains(i) ? .white : Color(white: 0.3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)

            // Tasks
            VStack(spacing: 0) {
                ForEach(tasks) { task in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.taskName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Text("\(String(format: "%02d:%02d", task.deadlineHour, task.deadlineMinute)) · \(task.monsterType.displayName)")
                                .font(.system(size: 11))
                                .foregroundColor(Color(white: 0.4))
                        }
                        Spacer()

                        Button { editingTask = task } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.4))
                                .padding(8)
                                .background(Color(white: 1, opacity: 0.07))
                                .clipShape(Circle())
                        }

                        Button {
                            modelContext.delete(task)
                            try? modelContext.save()
                            NotificationService.scheduleAll(tasks: self.tasks.filter { $0.id != task.id })
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(white: 0.4))
                                .padding(8)
                                .background(Color(white: 1, opacity: 0.07))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)

                    Rectangle()
                        .fill(Color(white: 1, opacity: 0.05))
                        .frame(height: 1)
                        .padding(.horizontal, 24)
                }
            }

            // Add task
            if tasks.count < 7 {
                let blocked: Set<Int> = routineIndex == 0 ? routine2Days : routine1Days
                let available = Array(Set(0...6).subtracting(blocked))
                Button {
                    showAddTask = AddTaskTarget(routineIndex: routineIndex, availableDays: available)
                } label: {
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
                .padding(.horizontal, 24)
            }
        }
    }

    @ViewBuilder
    private func divider() -> some View {
        Rectangle()
            .fill(Color(white: 1, opacity: 0.07))
            .frame(height: 1)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
    }
}
