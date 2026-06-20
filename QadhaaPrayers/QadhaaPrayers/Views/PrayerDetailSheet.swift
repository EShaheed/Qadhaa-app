import SwiftUI

struct PrayerDetailSheet: View {
    @EnvironmentObject var store: PrayerStore
    @Environment(\.dismiss) var dismiss
    let prayer: PrayerType

    @State private var owedText = ""
    @State private var prayedText = ""

    private let bgColor = Color(red: 0.09, green: 0.09, blue: 0.12)
    private let cardColor = Color(red: 0.14, green: 0.14, blue: 0.18)
    private let gold = Color(red: 0.82, green: 0.68, blue: 0.35)

    var data: PrayerData { store.prayers[prayer] ?? PrayerData(totalOwed: 0, totalPrayed: 0) }

    var body: some View {
        NavigationView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle().fill(prayer.color.opacity(0.15)).frame(width: 80, height: 80)
                        Image(systemName: prayer.icon).font(.system(size: 36)).foregroundColor(prayer.color)
                    }
                    Text(prayer.rawValue).font(.title2).fontWeight(.bold).foregroundColor(.white)
                    Text(prayer.arabicName).font(.title3).foregroundColor(.gray)
                }
                .padding(.top, 8)

                ZStack {
                    Circle().stroke(Color(red: 0.20, green: 0.20, blue: 0.25), lineWidth: 10)
                    Circle().trim(from: 0, to: data.progress)
                        .stroke(prayer.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5), value: data.progress)
                    VStack(spacing: 2) {
                        Text("\(data.totalPrayed)")
                            .font(.system(size: 36, weight: .bold, design: .rounded)).foregroundColor(.white)
                        Text("of \(data.totalOwed)").font(.caption).foregroundColor(.gray)
                    }
                }
                .frame(width: 130, height: 130)

                VStack(spacing: 16) {
                    Text("Tap to update count").font(.caption).foregroundColor(.gray)
                    HStack(spacing: 24) {
                        CounterButton(icon: "minus", color: Color(red: 0.99, green: 0.42, blue: 0.42), disabled: data.totalPrayed <= 0) {
                            withAnimation(.spring(response: 0.3)) { store.decrement(prayer) }
                        }
                        VStack(spacing: 4) {
                            Text("\(data.totalPrayed)")
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.3), value: data.totalPrayed)
                            Text("Prayed").font(.caption).foregroundColor(.gray)
                        }
                        .frame(minWidth: 100)
                        CounterButton(icon: "plus", color: prayer.color, disabled: data.totalPrayed >= data.totalOwed) {
                            withAnimation(.spring(response: 0.3)) { store.increment(prayer) }
                        }
                    }
                    HStack {
                        Image(systemName: data.isComplete ? "checkmark.circle.fill" : "clock.badge.xmark")
                            .foregroundColor(data.isComplete ? .green : .gray)
                        Text(data.isComplete ? "All prayers made up!" : "\(data.remaining) remaining")
                            .font(.subheadline).foregroundColor(data.isComplete ? .green : .gray)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(cardColor).cornerRadius(12)
                }

                VStack(spacing: 10) {
                    Text("Edit Total Count").font(.caption).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 12) {
                        editField(label: "Total Owed", value: data.totalOwed, binding: $owedText) { store.setCustomCount(for: prayer, owed: $0) }
                        editField(label: "Total Prayed", value: data.totalPrayed, binding: $prayedText) { store.setPrayedCount(for: prayer, prayed: $0) }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(bgColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(gold)
                }
            }
        }
    }

    private func editField(label: String, value: Int, binding: Binding<String>, onCommit: @escaping (Int) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundColor(.gray)
            TextField("\(value)", text: binding)
                .keyboardType(.numberPad).foregroundColor(.white)
                .padding(12).background(cardColor).cornerRadius(10)
                .onSubmit {
                    if let val = Int(binding.wrappedValue) { onCommit(val); binding.wrappedValue = "" }
                }
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(prayer.color.opacity(0.3), lineWidth: 1))
        }
    }
}

struct CounterButton: View {
    let icon: String
    let color: Color
    let disabled: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            guard !disabled else { return }
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isPressed = false }
            action()
        }) {
            ZStack {
                Circle().fill(disabled ? Color(red: 0.15, green: 0.15, blue: 0.18) : color.opacity(0.18)).frame(width: 70, height: 70)
                Circle().stroke(disabled ? Color(red: 0.20, green: 0.20, blue: 0.24) : color.opacity(0.4), lineWidth: 1.5).frame(width: 70, height: 70)
                Image(systemName: icon).font(.system(size: 26, weight: .semibold))
                    .foregroundColor(disabled ? Color(red: 0.30, green: 0.30, blue: 0.35) : color)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(disabled)
    }
}
