import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: PrayerStore
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if store.isSetupComplete {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem { Label("Dashboard", systemImage: "house.fill") }
                        .tag(0)
                    CalculatorView()
                        .tabItem { Label("Calculator", systemImage: "calendar.badge.clock") }
                        .tag(1)
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                        .tag(2)
                }
                .tint(Color(red: 0.82, green: 0.68, blue: 0.35))
            } else {
                SetupView()
            }
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.10))
    }
}
