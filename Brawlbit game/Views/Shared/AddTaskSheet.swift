import SwiftUI

struct AddTaskSheet: View {
    let existingTaskNames: [String]
    let onAdd: (String, MonsterType, Int, Int) -> Void

    @State private var selectedTemplate: MonsterTemplate? = nil
    @State private var hour: Int = 8
    @State private var minute: Int = 0
    @State private var monsterType: MonsterType = .demon
    @State private var showCustomInput = false
    @State private var customName = ""
    @FocusState private var customFieldFocused: Bool

    var body: some View {
        ZStack {
            Color(white: 0.1).ignoresSafeArea()

            if let template = selectedTemplate {
                configView(template: template)
                    .transition(.move(edge: .trailing))
            } else {
                catalogView
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: selectedTemplate?.id)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: Catalog

    private var catalogView: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(white: 0.28))
                .frame(width: 36, height: 4)
                .padding(.top, 14)
                .padding(.bottom, 20)

            Text("Choose a task")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 0) {

                    // ── Create your own ───────────────────────────────────
                    if showCustomInput {
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                TextField("Task name…", text: $customName)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .tint(.orange)
                                    .focused($customFieldFocused)
                                    .submitLabel(.go)
                                    .onSubmit { confirmCustom() }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color(white: 0.18))
                                    .cornerRadius(10)

                                Button(action: confirmCustom) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(customName.trimmingCharacters(in: .whitespaces).isEmpty ? Color(white: 0.25) : .orange)
                                }
                                .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                            .padding(.horizontal, 24)

                            if existingTaskNames.contains(customName.trimmingCharacters(in: .whitespaces)) {
                                Text("Already added")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color(white: 0.13))
                    } else {
                        Button {
                            showCustomInput = true
                            customFieldFocused = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                Text("Create your own")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.orange)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(white: 0.35))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }
                    }

                    Rectangle()
                        .fill(Color(white: 1, opacity: 0.08))
                        .frame(height: 1)
                        .padding(.horizontal, 24)

                    // ── Predefined catalog ────────────────────────────────
                    ForEach(MonsterCatalog.predefined) { template in
                        let isAdded = existingTaskNames.contains(template.taskName)
                        Button {
                            guard !isAdded else { return }
                            monsterType = template.monsterType
                            selectedTemplate = template
                        } label: {
                            HStack {
                                Text(template.taskName)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(isAdded ? Color(white: 0.35) : .white)
                                Spacer()
                                if isAdded {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.orange)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(white: 0.35))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        }
                        .disabled(isAdded)

                        Rectangle()
                            .fill(Color(white: 1, opacity: 0.06))
                            .frame(height: 1)
                            .padding(.horizontal, 24)
                    }
                }
            }
        }
    }

    private func confirmCustom() {
        let name = customName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !existingTaskNames.contains(name) else { return }
        selectedTemplate = MonsterTemplate(taskName: name, monsterType: .demon)
        monsterType = .demon
    }

    // MARK: Config

    @ViewBuilder
    private func configView(template: MonsterTemplate) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    selectedTemplate = nil
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.orange)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Text(template.taskName)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 28)

            Text("DEADLINE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 4)

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

            Text("CHOOSE YOUR MONSTER")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.orange)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

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
            .padding(.bottom, 24)

            Button("Add to lineup") {
                onAdd(template.taskName, monsterType, hour, minute)
            }
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
}
