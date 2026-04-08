import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \DayRecord.date, order: .reverse) private var records: [DayRecord]
    @State private var selectedRecord: DayRecord? = nil

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            if records.isEmpty {
                VStack(spacing: 8) {
                    Text("No battles yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Complete your first day to see history")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.6))
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("HISTORY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                                .tracking(1)
                            Spacer()
                            Text("\(records.count) days")
                                .font(.system(size: 11))
                                .foregroundColor(Color(white: 0.35))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 52)
                        .padding(.bottom, 16)

                        ForEach(records) { record in
                            Button { selectedRecord = record } label: {
                                HStack(spacing: 14) {
                                    // Colored circle icon
                                    ZStack {
                                        Circle()
                                            .fill(record.dayWon
                                                  ? Color.green.opacity(0.18)
                                                  : Color(red: 0.55, green: 0.08, blue: 0.08).opacity(0.5))
                                            .frame(width: 46, height: 46)
                                        Text(record.dayWon ? "⚔️" : "💀")
                                            .font(.system(size: 22))
                                    }

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)

                                        // W/L label
                                        Text("\(record.victoriesCount)W · \(record.defeatsCount)L · \(record.battles.count) tasks")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(white: 0.4))

                                        // Mini task completion bar
                                        if record.battles.count > 0 {
                                            let ratio = Double(record.victoriesCount) / Double(record.battles.count)
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(Color(white: 0.18))
                                                        .frame(height: 4)
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(record.dayWon ? Color.green : Color(red: 0.8, green: 0.2, blue: 0.2))
                                                        .frame(width: geo.size.width * ratio, height: 4)
                                                }
                                            }
                                            .frame(height: 4)
                                        }
                                    }

                                    Spacer()

                                    Text(record.dayWon ? "WON" : "LOST")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(record.dayWon ? .green : .red)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background((record.dayWon ? Color.green : Color.red).opacity(0.12))
                                        .cornerRadius(6)

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color(white: 0.25))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)

                            Rectangle()
                                .fill(Color(white: 1, opacity: 0.06))
                                .frame(height: 1)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(item: $selectedRecord) { record in
            DayDetailSheet(record: record)
        }
    }
}

// MARK: - Day Detail Sheet

private struct DayDetailSheet: View {
    let record: DayRecord
    @Environment(\.dismiss) private var dismiss

    private var accentColor: Color {
        record.dayWon ? .green : Color(red: 0.75, green: 0.15, blue: 0.15)
    }

    var body: some View {
        ZStack {
            // Base dark background
            Color(white: 0.06).ignoresSafeArea()

            // Subtle gradient at the top
            VStack {
                LinearGradient(
                    colors: [
                        accentColor.opacity(0.22),
                        accentColor.opacity(0.06),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 220)
                .ignoresSafeArea(edges: .top)
                Spacer()
            }

            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(white: 0.28))
                    .frame(width: 36, height: 4)
                    .padding(.top, 14)
                    .padding(.bottom, 28)

                // Result header
                VStack(spacing: 8) {
                    Text(record.dayWon ? "⚔️" : "💀")
                        .font(.system(size: 56))

                    Text(record.dayWon ? "VICTORY" : "DEFEAT")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(accentColor)

                    Text(record.date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.45))
                }
                .padding(.bottom, 32)

                // Score
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("\(record.victoriesCount)")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.green)
                        Text("Won")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.4))
                    }
                    Rectangle()
                        .fill(Color(white: 0.2))
                        .frame(width: 1, height: 36)
                    VStack(spacing: 4) {
                        Text("\(record.defeatsCount)")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.red)
                        Text("Lost")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.4))
                    }
                }
                .padding(.bottom, 32)

                // Battle list
                VStack(spacing: 0) {
                    HStack {
                        Text("TASKS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                            .tracking(1)
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)

                    let sorted = record.battles.sorted { a, b in
                        if a.result != b.result {
                            return a.result == .victory
                        }
                        return a.taskName < b.taskName
                    }

                    ForEach(Array(sorted.enumerated()), id: \.offset) { _, battle in
                        HStack(spacing: 14) {
                            Image(systemName: battle.result == .victory ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(battle.result == .victory ? .green : .red)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(battle.taskName)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                if let completedAt = battle.completedAt {
                                    Text("Completed at \(completedAt.formatted(date: .omitted, time: .shortened))")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(white: 0.4))
                                } else {
                                    Text("Not completed")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(white: 0.3))
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)

                        Rectangle()
                            .fill(Color(white: 1, opacity: 0.06))
                            .frame(height: 1)
                            .padding(.horizontal, 28)
                    }
                }

                Spacer()

                Button("Close") { dismiss() }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
                    .padding(.top, 20)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
