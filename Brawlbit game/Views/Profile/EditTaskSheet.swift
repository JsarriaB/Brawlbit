import SwiftUI
import SwiftData

struct EditTaskSheet: View {
    let task: MonsterTask
    let blockedDays: Set<Int>
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MonsterTask.order) private var allTasks: [MonsterTask]

    @State private var hour: Int
    @State private var minute: Int
    @State private var monsterType: MonsterType
    @State private var selectedDays: Set<Int>

    private let dayLetters = ["M", "Tu", "W", "Th", "F", "Sa", "Su"]

    init(task: MonsterTask, blockedDays: Set<Int>) {
        self.task = task
        self.blockedDays = blockedDays
        _hour         = State(initialValue: task.deadlineHour)
        _minute       = State(initialValue: task.deadlineMinute)
        _monsterType  = State(initialValue: task.monsterType)
        _selectedDays = State(initialValue: Set(task.daysOfWeek))
    }

    var body: some View {
        ZStack {
            Color(white: 0.1).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(white: 0.28))
                    .frame(width: 36, height: 4)
                    .padding(.top, 14)
                    .padding(.bottom, 20)

                Text(task.taskName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // Deadline
                        sectionLabel("DEADLINE")
                        HStack(spacing: 0) {
                            Picker("Hour", selection: $hour) {
                                ForEach(0..<24, id: \.self) {
                                    Text(String(format: "%02d", $0)).tag($0)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                            .colorScheme(.dark)

                            Text(":")
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            Picker("Minute", selection: $minute) {
                                ForEach(0..<60, id: \.self) {
                                    Text(String(format: "%02d", $0)).tag($0)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                            .colorScheme(.dark)
                        }
                        .frame(height: 100)
                        .padding(.bottom, 20)

                        // Days
                        sectionLabel("ACTIVE DAYS")
                        HStack(spacing: 6) {
                            ForEach(0..<7, id: \.self) { i in
                                let blocked = blockedDays.contains(i)
                                Button {
                                    guard !blocked else { return }
                                    if selectedDays.contains(i) { selectedDays.remove(i) }
                                    else { selectedDays.insert(i) }
                                } label: {
                                    Text(dayLetters[i])
                                        .font(.system(size: 13, weight: .bold))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            selectedDays.contains(i) ? Color.orange :
                                            blocked ? Color(white: 0.1) :
                                            Color(white: 0.14)
                                        )
                                        .foregroundColor(
                                            selectedDays.contains(i) ? .white :
                                            blocked ? Color(white: 0.22) :
                                            Color(white: 0.5)
                                        )
                                        .clipShape(Circle())
                                }
                                .disabled(blocked)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                        // Monster
                        sectionLabel("MONSTER")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(MonsterType.allCases, id: \.self) { type in
                                    AnimatedMonsterCard(
                                        monsterType: type,
                                        isSelected: monsterType == type
                                    ) { monsterType = type }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 28)
                    }
                }

                // Save button
                Button("Save changes") { save() }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    @ViewBuilder
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.orange)
            .tracking(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
    }

    private func save() {
        task.deadlineHour   = hour
        task.deadlineMinute = minute
        task.monsterType    = monsterType
        if !selectedDays.isEmpty {
            task.daysOfWeek = Array(selectedDays)
        }
        try? modelContext.save()
        NotificationService.scheduleAll(tasks: allTasks)
        dismiss()
    }
}
