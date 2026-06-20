import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: PrayerStore
    @State private var selectedPrayer: PrayerType? = nil

    private let bgColor = Color(red: 0.07, green: 0.07, blue: 0.10)
    private let cardColor = Color(red: 0.12, green: 0.12, blue: 0.16)
    private let gold = Color(red: 0.82, green: 0.68, blue: 0.35)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    overallProgressCard
                    prayerGrid
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Qadhaa Prayers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("بِسْمِ اللَّهِ").font(.caption).foregroundColor(gold)
                }
            }
        }
        .sheet(item: $selectedPrayer) { prayer in
            PrayerDetailSheet(prayer: prayer).environmentObject(store)
        }
    }

    private var overallProgressCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle().stroke(Color(red: 0.20, green: 0.20, blue: 0.25), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: store.overallProgress)
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [gold, Color(red: 0.99, green: 0.84, blue: 0.55)]), center: .center),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: store.overallProgress)
                VStack(spacing: 4) {
                    Text("\(Int(store.overallProgress * 100))%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Complete").font(.caption).foregroundColor(.gray)
                }
            }
            .frame(width: 160, height: 160)

            HStack(spacing: 0) {
                statItem(value: store.totalPrayed, label: "Prayed", color: gold)
                Divider().frame(height: 40).background(Color(red: 0.25, green: 0.25, blue: 0.30))
                statItem(value: store.totalRemaining, label: "Remaining", color: Color(red: 0.99, green: 0.42, blue: 0.42))
                Divider().frame(height: 40).background(Color(red: 0.25, green: 0.25, blue: 0.30))
                statItem(value: store.totalOwed, label: "Total", color: .gray)
            }
        }
        .padding(24)
        .background(cardColor)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(gold.opacity(0.2), lineWidth: 1))
    }

    private func statItem(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(color)
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private var prayerGrid: some View {
        VStack(spacing: 12) {
            Text("Individual Prayers").font(.subheadline).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading)
            ForEach(PrayerType.allCases) { prayer in
                PrayerRowCard(prayer: prayer) { selectedPrayer = prayer }
                    .environmentObject(store)
            }
        }
    }
}

struct PrayerRowCard: View {
    @EnvironmentObject var store: PrayerStore
    let prayer: PrayerType
    let onTap: () -> Void
    private let cardColor = Color(red: 0.12, green: 0.12, blue: 0.16)

    var body: some View {
        let data = store.prayers[prayer] ?? PrayerData(totalOwed: 0, totalPrayed: 0)
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(prayer.color.opacity(0.15)).frame(width: 44, height: 44)
                        Image(systemName: prayer.icon).font(.system(size: 20)).foregroundColor(prayer.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(prayer.rawValue).font(.headline).foregroundColor(.white)
                            Text(prayer.arabicName).font(.caption).foregroundColor(.gray)
                        }
                        Text("\(data.remaining) remaining of \(data.totalOwed)").font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(data.totalPrayed)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(data.isComplete ? prayer.color : .white)
                        Text("prayed").font(.caption2).foregroundColor(.gray)
                    }
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.20, green: 0.20, blue: 0.25)).frame(height: 6)
                        RoundedRectangle(cornerRadius: 4).fill(prayer.color)
                            .frame(width: geo.size.width * data.progress, height: 6)
                            .animation(.easeInOut(duration: 0.4), value: data.progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(16)
            .background(cardColor)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(prayer.color.opacity(data.isComplete ? 0.5 : 0.12), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
