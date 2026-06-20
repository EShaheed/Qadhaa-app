import SwiftUI

struct SetupView: View {
    @EnvironmentObject var store: PrayerStore
    @State private var daysText: String = ""
    @State private var customCounts: [PrayerType: String] = [:]
    @State private var useCustomMode = false
    @State private var showError = false
    @FocusState private var focusedField: PrayerType?

    private let gold = Color(red: 0.82, green: 0.68, blue: 0.35)
    private let bgColor = Color(red: 0.07, green: 0.07, blue: 0.10)
    private let cardColor = Color(red: 0.12, green: 0.12, blue: 0.16)

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("بِسْمِ اللَّهِ")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(gold)
                    Text("Qadhaa Prayers")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Track your missed prayers and\nmake them up with ease")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 48)

                HStack(spacing: 0) {
                    modeButton(title: "By Days", selected: !useCustomMode) { withAnimation { useCustomMode = false } }
                    modeButton(title: "Custom", selected: useCustomMode) { withAnimation { useCustomMode = true } }
                }
                .background(cardColor)
                .cornerRadius(12)
                .padding(.horizontal)

                if useCustomMode { customModeSection } else { daysModeSection }

                Button(action: handleSetup) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Begin Tracking").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(gold)
                    .foregroundColor(.black)
                    .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(bgColor.ignoresSafeArea())
        .alert("Invalid Input", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter valid numbers greater than 0.")
        }
    }

    private var daysModeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Days to Make Up").font(.headline).foregroundColor(.white).padding(.horizontal)
            VStack(spacing: 4) {
                TextField("e.g. 365", text: $daysText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(cardColor)
                    .cornerRadius(14)
                    .padding(.horizontal)
                if let days = Int(daysText), days > 0 {
                    VStack(spacing: 8) {
                        ForEach(PrayerType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon).foregroundColor(type.color).frame(width: 24)
                                Text(type.rawValue).foregroundColor(.gray)
                                Spacer()
                                Text("\(days) prayers").foregroundColor(.white).fontWeight(.medium)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    private var customModeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Set prayer counts individually").font(.headline).foregroundColor(.white).padding(.horizontal)
            VStack(spacing: 10) {
                ForEach(PrayerType.allCases) { type in
                    HStack {
                        Image(systemName: type.icon).foregroundColor(type.color).frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(type.rawValue).foregroundColor(.white).fontWeight(.medium)
                            Text(type.arabicName).font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        TextField("0", text: Binding(
                            get: { customCounts[type] ?? "" },
                            set: { customCounts[type] = $0 }
                        ))
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                        .padding(.vertical, 8).padding(.horizontal, 12)
                        .background(Color(red: 0.18, green: 0.18, blue: 0.22))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .focused($focusedField, equals: type)
                    }
                    .padding()
                    .background(cardColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
    }

    private func modeButton(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selected ? Color(red: 0.82, green: 0.68, blue: 0.35) : Color.clear)
                .foregroundColor(selected ? .black : .gray)
                .cornerRadius(10)
        }
    }

    private func handleSetup() {
        if useCustomMode {
            var allValid = true
            for type in PrayerType.allCases {
                guard let val = Int(customCounts[type] ?? "0"), val >= 0 else { allValid = false; break }
                store.setCustomCount(for: type, owed: val)
            }
            if !allValid { showError = true; return }
            store.isSetupComplete = true
            store.save()
        } else {
            guard let days = Int(daysText), days > 0 else { showError = true; return }
            store.setupFromDays(days)
        }
    }
}
