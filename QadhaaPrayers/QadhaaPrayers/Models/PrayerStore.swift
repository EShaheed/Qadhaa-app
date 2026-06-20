import Foundation
import SwiftUI

enum PrayerType: String, CaseIterable, Codable, Identifiable {
    case fajr    = "Fajr"
    case dhuhr   = "Dhuhr"
    case asr     = "Asr"
    case maghrib = "Maghrib"
    case isha    = "Isha"

    var id: String { rawValue }

    var arabicName: String {
        switch self {
        case .fajr:    return "الفجر"
        case .dhuhr:   return "الظهر"
        case .asr:     return "العصر"
        case .maghrib: return "المغرب"
        case .isha:    return "العشاء"
        }
    }

    var icon: String {
        switch self {
        case .fajr:    return "sunrise.fill"
        case .dhuhr:   return "sun.max.fill"
        case .asr:     return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isha:    return "moon.stars.fill"
        }
    }

    var rakaat: Int {
        switch self {
        case .fajr:    return 2
        case .dhuhr:   return 4
        case .asr:     return 4
        case .maghrib: return 3
        case .isha:    return 4
        }
    }

    var color: Color {
        switch self {
        case .fajr:    return Color(red: 0.44, green: 0.78, blue: 0.94)
        case .dhuhr:   return Color(red: 0.99, green: 0.84, blue: 0.35)
        case .asr:     return Color(red: 0.99, green: 0.64, blue: 0.24)
        case .maghrib: return Color(red: 0.99, green: 0.42, blue: 0.42)
        case .isha:    return Color(red: 0.60, green: 0.48, blue: 0.99)
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .fajr:    return [Color(red: 0.22, green: 0.45, blue: 0.62), Color(red: 0.12, green: 0.28, blue: 0.45)]
        case .dhuhr:   return [Color(red: 0.55, green: 0.45, blue: 0.10), Color(red: 0.38, green: 0.30, blue: 0.05)]
        case .asr:     return [Color(red: 0.55, green: 0.32, blue: 0.08), Color(red: 0.38, green: 0.22, blue: 0.04)]
        case .maghrib: return [Color(red: 0.55, green: 0.18, blue: 0.18), Color(red: 0.38, green: 0.10, blue: 0.10)]
        case .isha:    return [Color(red: 0.28, green: 0.20, blue: 0.50), Color(red: 0.18, green: 0.12, blue: 0.35)]
        }
    }
}

struct PrayerData: Codable {
    var totalOwed: Int
    var totalPrayed: Int

    var remaining: Int { max(0, totalOwed - totalPrayed) }
    var progress: Double { totalOwed > 0 ? min(1.0, Double(totalPrayed) / Double(totalOwed)) : 0 }
    var isComplete: Bool { totalPrayed >= totalOwed && totalOwed > 0 }
}

class PrayerStore: ObservableObject {
    @Published var prayers: [PrayerType: PrayerData] = [:]
    @Published var daysToMakeUp: Int = 0
    @Published var isSetupComplete: Bool = false
    @Published var dailyQadhaRate: Int = 5

    private let storageKey = "qadhaa_v2_data"

    init() {
        for type in PrayerType.allCases {
            prayers[type] = PrayerData(totalOwed: 0, totalPrayed: 0)
        }
        load()
    }

    var totalOwed: Int { prayers.values.reduce(0) { $0 + $1.totalOwed } }
    var totalPrayed: Int { prayers.values.reduce(0) { $0 + $1.totalPrayed } }
    var totalRemaining: Int { max(0, totalOwed - totalPrayed) }
    var overallProgress: Double { totalOwed > 0 ? min(1.0, Double(totalPrayed) / Double(totalOwed)) : 0 }

    func setupFromDays(_ days: Int) {
        daysToMakeUp = days
        for type in PrayerType.allCases {
            let currentPrayed = prayers[type]?.totalPrayed ?? 0
            prayers[type] = PrayerData(totalOwed: days, totalPrayed: min(currentPrayed, days))
        }
        isSetupComplete = true
        save()
    }

    func setCustomCount(for type: PrayerType, owed: Int) {
        let currentPrayed = prayers[type]?.totalPrayed ?? 0
        prayers[type] = PrayerData(totalOwed: max(0, owed), totalPrayed: min(currentPrayed, max(0, owed)))
        save()
    }

    func setPrayedCount(for type: PrayerType, prayed: Int) {
        let owed = prayers[type]?.totalOwed ?? 0
        prayers[type] = PrayerData(totalOwed: owed, totalPrayed: max(0, min(prayed, owed)))
        save()
    }

    func increment(_ type: PrayerType) {
        guard var data = prayers[type] else { return }
        if data.totalPrayed < data.totalOwed {
            data.totalPrayed += 1
            prayers[type] = data
            save()
        }
    }

    func decrement(_ type: PrayerType) {
        guard var data = prayers[type], data.totalPrayed > 0 else { return }
        data.totalPrayed -= 1
        prayers[type] = data
        save()
    }

    struct CompletionTime {
        let years: Int
        let months: Int
        let days: Int
        let totalDays: Int
    }

    func timeToComplete() -> CompletionTime? {
        guard dailyQadhaRate > 0, totalRemaining > 0 else { return nil }
        let totalDays = Int(ceil(Double(totalRemaining) / Double(dailyQadhaRate)))
        let years = totalDays / 365
        let months = (totalDays % 365) / 30
        let days = (totalDays % 365) % 30
        return CompletionTime(years: years, months: months, days: days, totalDays: totalDays)
    }

    func estimatedCompletionDate() -> Date? {
        guard let time = timeToComplete() else { return nil }
        return Calendar.current.date(byAdding: .day, value: time.totalDays, to: Date())
    }

    private struct StorageModel: Codable {
        var prayers: [String: PrayerData]
        var daysToMakeUp: Int
        var isSetupComplete: Bool
        var dailyQadhaRate: Int
    }

    func save() {
        let model = StorageModel(
            prayers: Dictionary(uniqueKeysWithValues: prayers.map { ($0.key.rawValue, $0.value) }),
            daysToMakeUp: daysToMakeUp,
            isSetupComplete: isSetupComplete,
            dailyQadhaRate: dailyQadhaRate
        )
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let model = try? JSONDecoder().decode(StorageModel.self, from: data) else { return }
        for (key, value) in model.prayers {
            if let type = PrayerType(rawValue: key) {
                prayers[type] = value
            }
        }
        daysToMakeUp = model.daysToMakeUp
        isSetupComplete = model.isSetupComplete
        dailyQadhaRate = model.dailyQadhaRate
    }

    func exportBackupData() -> Data? {
        let model = StorageModel(
            prayers: Dictionary(uniqueKeysWithValues: prayers.map { ($0.key.rawValue, $0.value) }),
            daysToMakeUp: daysToMakeUp,
            isSetupComplete: isSetupComplete,
            dailyQadhaRate: dailyQadhaRate
        )
        return try? JSONEncoder().encode(model)
    }

    func importBackup(from data: Data) -> Bool {
        guard let model = try? JSONDecoder().decode(StorageModel.self, from: data) else { return false }
        for (key, value) in model.prayers {
            if let type = PrayerType(rawValue: key) {
                prayers[type] = value
            }
        }
        daysToMakeUp = model.daysToMakeUp
        isSetupComplete = model.isSetupComplete
        dailyQadhaRate = model.dailyQadhaRate
        save()
        return true
    }

    func resetAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        daysToMakeUp = 0
        isSetupComplete = false
        dailyQadhaRate = 5
        for type in PrayerType.allCases {
            prayers[type] = PrayerData(totalOwed: 0, totalPrayed: 0)
        }
    }
}
