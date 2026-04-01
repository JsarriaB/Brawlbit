import SwiftUI
import SwiftData

struct DaySummaryView: View {
    @Query(sort: \DayRecord.date, order: .reverse) private var records: [DayRecord]
    @Environment(\.dismiss) private var dismiss

    var latest: DayRecord? { records.first }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Text(latest?.dayWon == true ? "⚔️" : "💀")
                    .font(.system(size: 80))
                Text(latest?.dayWon == true ? "VICTORY!" : "DEFEATED TODAY")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(latest?.dayWon == true ? .green : .red)

                if let record = latest {
                    Text("\(record.victoriesCount) won · \(record.defeatsCount) lost")
                        .font(.title3)
                        .foregroundColor(.white)

                    VStack(spacing: 6) {
                        ForEach(record.battles, id: \.taskName) { battle in
                            HStack {
                                Text(battle.result == .victory ? "✅" : "❌")
                                Text(battle.taskName)
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(.horizontal, 48)
                        }
                    }
                }

                Spacer()

                Button("Back to camp") { dismiss() }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            }
        }
    }
}
