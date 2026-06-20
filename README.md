# Qadhaa Prayers — iOS App

A beautifully designed iOS app (SwiftUI) for tracking and making up missed (Qadhaa) prayers.

## Features

### Dashboard
- **Total progress ring** — shows percentage of all Qadhaa prayers completed
- **Per-prayer rows** with animated progress bars showing remaining / total
- Tap any prayer (Fajr, Dhuhr, Asr, Maghrib, Isha) to open a detail sheet

### Prayer Detail Sheet
- Large **+** and **−** buttons to log or remove individual prayer units
- Animated count display with progress ring
- Edit total owed and total prayed directly from the sheet

### Setup
- **By Days** — enter number of days missed; app auto-calculates per-prayer counts
- **Custom** — set each prayer's count individually
- Can be re-run anytime from Settings

### Calculator Tab
- Set your **daily Qadha rate** (how many you pray per day)
- Instantly see estimated **years / months / days** to complete
- Shows the estimated **calendar date** of completion
- Quranic verse for motivation

### Settings Tab
- Adjust individual prayer owed counts
- Export backup as JSON (share via AirDrop, Files, email, etc.)
- Import backup from a `.json` file
- Full reset option

## Project Structure

```
QadhaaPrayers/
├── QadhaaPrayers.xcodeproj/
└── QadhaaPrayers/
    ├── QadhaaPrayersApp.swift
    ├── Models/
    │   └── PrayerStore.swift
    └── Views/
        ├── ContentView.swift
        ├── SetupView.swift
        ├── DashboardView.swift
        ├── PrayerDetailSheet.swift
        ├── CalculatorView.swift
        └── SettingsView.swift
```

## Requirements

- Xcode 15+
- iOS 16.0+
- Swift 5.9+

## How to Open

1. Open `QadhaaPrayers/QadhaaPrayers.xcodeproj` in Xcode
2. Select a simulator or your device
3. Press **⌘R** to build and run

## Design

- Forced **dark mode** with a dark charcoal background (`#121214`)
- **Gold accent** (`#D1AE5A`) inspired by Islamic geometric art
- Per-prayer color coding (dawn blue, noon yellow, afternoon orange, dusk red, night purple)
- Arabic prayer names displayed alongside English
- Quranic verse in the Calculator tab
