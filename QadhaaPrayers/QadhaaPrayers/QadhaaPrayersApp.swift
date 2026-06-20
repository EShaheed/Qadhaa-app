import SwiftUI

@main
struct QadhaaPrayersApp: App {
    @StateObject private var store = PrayerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
