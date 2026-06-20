import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var store: PrayerStore
    @State private var showResetAlert = false
    @State private var showSetupSheet = false
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var importError = false
    @State private var importSuccess = false
    @State private var exportData: Data? = nil

    private let bgColor = Color(red: 0.07, green: 0.07, blue: 0.10)
    private let cardColor = Color(red: 0.12, green: 0.12, blue: 0.16)
    private let gold = Color(red: 0.82, green: 0.68, blue: 0.35)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill").font(.system(size: 40)).foregroundColor(gold)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Progress").font(.headline).foregroundColor(.white)
                                Text("\(store.totalPrayed) of \(store.totalOwed) completed").font(.subheadline).foregroundColor(.gray)
                            }
                            Spacer()
                            Text("\(Int(store.overallProgress * 100))%")
                                .font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(gold)
                        }
                    }
                    .padding(20).background(cardColor).cornerRadius(20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(icon: "pencil.circle.fill", title: "Adjust Prayer Counts")
                        ForEach(PrayerType.allCases) { prayer in
                            AdjustPrayerRow(prayer: prayer).environmentObject(store)
                        }
                    }
                    .padding(16).background(cardColor).cornerRadius(20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(icon: "arrow.counterclockwise.circle.fill", title: "Recalculate from Days")
                        Button(action: { showSetupSheet = true }) {
                            HStack {
                                Text("Re-run setup wizard").foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            .padding().background(Color(red: 0.16, green: 0.16, blue: 0.20)).cornerRadius(12)
                        }
                    }
                    .padding(16).background(cardColor).cornerRadius(20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(icon: "externaldrive.fill", title: "Backup & Restore")
                        Button(action: exportBackup) { settingsRow(icon: "square.and.arrow.up", label: "Export Backup", color: .blue) }
                        Button(action: { showImportPicker = true }) { settingsRow(icon: "square.and.arrow.down", label: "Import Backup", color: .green) }
                    }
                    .padding(16).background(cardColor).cornerRadius(20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(icon: "exclamationmark.triangle.fill", title: "Danger Zone")
                        Button(action: { showResetAlert = true }) { settingsRow(icon: "trash.fill", label: "Reset All Data", color: .red) }
                    }
                    .padding(16).background(cardColor).cornerRadius(20)

                    VStack(spacing: 6) {
                        Text("Qadhaa Prayers").font(.caption).foregroundColor(.gray)
                        Text("Version 1.0").font(.caption2).foregroundColor(Color(red: 0.30, green: 0.30, blue: 0.35))
                        Text("اللهم تقبل منا").font(.caption).foregroundColor(gold.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity).padding()

                    Spacer(minLength: 20)
                }
                .padding(.horizontal).padding(.top, 8)
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showSetupSheet) { SetupView().environmentObject(store) }
        .sheet(isPresented: $showExportSheet) { if let data = exportData { ShareSheet(items: [data]) } }
        .fileImporter(isPresented: $showImportPicker, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource(), let data = try? Data(contentsOf: url) else { importError = true; return }
                url.stopAccessingSecurityScopedResource()
                if store.importBackup(from: data) { importSuccess = true } else { importError = true }
            case .failure: importError = true
            }
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { store.resetAll() }
        } message: { Text("This will permanently delete all your prayer tracking data. This cannot be undone.") }
        .alert("Import Failed", isPresented: $importError) { Button("OK", role: .cancel) {} } message: { Text("The backup file could not be read.") }
        .alert("Import Successful", isPresented: $importSuccess) { Button("OK", role: .cancel) {} } message: { Text("Your backup has been restored successfully.") }
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(gold)
            Text(title).font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
        }
    }

    private func settingsRow(icon: String, label: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(color).frame(width: 24)
            Text(label).foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
        }
        .padding().background(Color(red: 0.16, green: 0.16, blue: 0.20)).cornerRadius(12)
    }

    private func exportBackup() {
        guard let data = store.exportBackupData() else { return }
        exportData = data
        showExportSheet = true
    }
}

struct AdjustPrayerRow: View {
    @EnvironmentObject var store: PrayerStore
    let prayer: PrayerType
    @State private var owedText: String = ""
    @FocusState private var isFocused: Bool
    var data: PrayerData { store.prayers[prayer] ?? PrayerData(totalOwed: 0, totalPrayed: 0) }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: prayer.icon).foregroundColor(prayer.color).frame(width: 24)
            Text(prayer.rawValue).foregroundColor(.white)
            Spacer()
            HStack(spacing: 8) {
                Text("Owed:").font(.caption).foregroundColor(.gray)
                TextField("\(data.totalOwed)", text: $owedText)
                    .keyboardType(.numberPad).frame(width: 70).multilineTextAlignment(.trailing)
                    .padding(.vertical, 6).padding(.horizontal, 10)
                    .background(Color(red: 0.18, green: 0.18, blue: 0.22)).cornerRadius(8)
                    .foregroundColor(.white).focused($isFocused)
                    .onSubmit { if let val = Int(owedText) { store.setCustomCount(for: prayer, owed: val) }; owedText = "" }
            }
        }
        .padding(.vertical, 8).padding(.horizontal, 4)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
