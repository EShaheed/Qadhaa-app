import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject var store: PrayerStore

    private let bgColor = Color(red: 0.07, green: 0.07, blue: 0.10)
    private let cardColor = Color(red: 0.12, green: 0.12, blue: 0.16)
    private let gold = Color(red: 0.82, green: 0.68, blue: 0.35)

    var completionTime: PrayerStore.CompletionTime? { store.timeToComplete() }
    var completionDate: Date? { store.estimatedCompletionDate() }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock").font(.system(size: 40)).foregroundColor(gold)
                        Text("Completion Calculator").font(.title3).fontWeight(.bold).foregroundColor(.white)
                        Text("How long will it take to finish all\nyour Qadhaa prayers?")
                            .font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(24).background(cardColor).cornerRadius(20)

                    HStack(spacing: 12) {
                        summaryCard(value: store.totalRemaining, label: "Prayers Left", color: Color(red: 0.99, green: 0.42, blue: 0.42))
                        summaryCard(value: store.totalOwed, label: "Total Owed", color: .gray)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Qadha Rate").font(.headline).foregroundColor(.white)
                        Text("How many Qadhaa prayers do you pray per day?").font(.caption).foregroundColor(.gray)
                        HStack(spacing: 16) {
                            Button(action: { if store.dailyQadhaRate > 1 { store.dailyQadhaRate -= 1; store.save() } }) {
                                Image(systemName: "minus.circle.fill").font(.system(size: 32)).foregroundColor(gold)
                            }
                            Text("\(store.dailyQadhaRate)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundColor(.white).frame(minWidth: 80).multilineTextAlignment(.center)
                                .contentTransition(.numericText()).animation(.spring(response: 0.3), value: store.dailyQadhaRate)
                            Button(action: { store.dailyQadhaRate += 1; store.save() }) {
                                Image(systemName: "plus.circle.fill").font(.system(size: 32)).foregroundColor(gold)
                            }
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.14, green: 0.14, blue: 0.18)).cornerRadius(14)

                        HStack(spacing: 8) {
                            ForEach([1, 3, 5, 10, 15, 20], id: \.self) { val in
                                Button(action: { store.dailyQadhaRate = val; store.save() }) {
                                    Text("\(val)").font(.callout).fontWeight(.medium)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(store.dailyQadhaRate == val ? gold : Color(red: 0.18, green: 0.18, blue: 0.22))
                                        .foregroundColor(store.dailyQadhaRate == val ? .black : .gray)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(20).background(cardColor).cornerRadius(20)

                    if let time = completionTime {
                        VStack(spacing: 20) {
                            Text("Estimated Completion").font(.subheadline).foregroundColor(.gray)
                            HStack(spacing: 16) {
                                timeUnitView(value: time.years, unit: "Years")
                                Text(":").font(.title).foregroundColor(gold).offset(y: -8)
                                timeUnitView(value: time.months, unit: "Months")
                                Text(":").font(.title).foregroundColor(gold).offset(y: -8)
                                timeUnitView(value: time.days, unit: "Days")
                            }
                            Divider().background(Color(red: 0.22, green: 0.22, blue: 0.28))
                            HStack {
                                Image(systemName: "calendar").foregroundColor(gold)
                                if let date = completionDate {
                                    Text("Est. completion: \(date, style: .date)").font(.subheadline).foregroundColor(.white)
                                }
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "info.circle").foregroundColor(.gray)
                                Text("At \(store.dailyQadhaRate) prayer\(store.dailyQadhaRate == 1 ? "" : "s") per day, \(time.totalDays) total days needed")
                                    .font(.caption).foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(LinearGradient(colors: [Color(red: 0.18, green: 0.15, blue: 0.08), Color(red: 0.12, green: 0.12, blue: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(gold.opacity(0.3), lineWidth: 1))
                    } else if store.totalRemaining == 0 && store.totalOwed > 0 {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 48)).foregroundColor(.green)
                            Text("Alhamdulillah!").font(.title2).fontWeight(.bold).foregroundColor(.white)
                            Text("All your Qadhaa prayers are complete.").font(.subheadline).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity).padding(32).background(cardColor).cornerRadius(20)
                    }

                    VStack(spacing: 8) {
                        Text("\"وَأَقِيمُوا الصَّلَاةَ\"")
                            .font(.system(size: 18, weight: .medium)).foregroundColor(gold)
                        Text("\"And establish prayer\" — Quran 2:43").font(.caption).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity).padding(20).background(cardColor).cornerRadius(16)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal).padding(.top, 8)
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Calculator")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func summaryCard(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)").font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(color)
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding(16).background(cardColor).cornerRadius(14)
    }

    private func timeUnitView(value: Int, unit: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded)).foregroundColor(.white)
                .contentTransition(.numericText()).animation(.spring(response: 0.3), value: value)
            Text(unit).font(.caption).foregroundColor(.gray)
        }
        .frame(minWidth: 70).padding(.vertical, 12).padding(.horizontal, 8)
        .background(Color(red: 0.16, green: 0.14, blue: 0.10)).cornerRadius(12)
    }
}
