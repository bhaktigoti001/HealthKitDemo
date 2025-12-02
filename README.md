# HealthKit iOS App

A comprehensive iOS health tracking application built with SwiftUI that integrates with Apple's HealthKit framework to monitor and visualize your health metrics.

## Features

### 📊 Dashboard
- **Real-time Health Metrics**: View your current step count, heart rate, active energy, and sleep hours
- **Weekly Progress**: Visualize your weekly step progress with an interactive chart
- **Sync Status**: Monitor the last sync time and connection status with HealthKit
- **Device Management**: View all connected health devices (Apple Watch, fitness trackers, etc.)
- **Manual Entry**: Add manual step entries when needed

### 📈 Analytics
- **Interactive Charts**: Beautiful bar charts powered by DGCharts for visualizing health data
- **Multiple Metrics**: Track Steps, Heart Rate, Active Energy, and Sleep
- **Flexible Time Ranges**: View data for 1 Week, 1 Month, 6 Months, or 1 Year
- **Zoom & Pan**: Interactive chart controls for detailed data exploration

### 📉 Statistics
- **Comprehensive Stats**: View detailed statistics including:
  - Steps (today, best day, average)
  - Active Energy (today, best day)
  - Heart Rate (resting, maximum)
  - Sleep (average, best)
- **Time Range Selection**: Filter statistics by Today, Week, Month, or Year
- **Achievement System**: Track your health achievements and milestones

## Requirements

- iOS 14.0 or later
- Xcode 12.0 or later
- Swift 5.0 or later
- CocoaPods (for dependency management)
- Apple Developer Account (for HealthKit entitlements)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd HealthKit
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Open the workspace**
   ```bash
   open HealthApp.xcworkspace
   ```
   ⚠️ **Important**: Always open the `.xcworkspace` file, not the `.xcodeproj` file when using CocoaPods.

4. **Configure HealthKit Entitlements**
   - The app already includes HealthKit entitlements in `HealthApp.entitlements`
   - Ensure your Apple Developer account has HealthKit capability enabled
   - In Xcode, go to Signing & Capabilities and verify HealthKit is enabled

5. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## Project Structure

```
HealthApp/
├── HealthAppApp.swift          # Main app entry point
├── Manager/
│   └── HealthKitManager.swift  # Core HealthKit integration and data management
├── Modules/
│   ├── Dashboard/              # Dashboard module
│   │   ├── Model/              # Data models
│   │   └── Views/              # SwiftUI views
│   ├── Analytics/              # Analytics module
│   │   ├── Model/              # Analytics models and enums
│   │   ├── ViewModel/          # Analytics view model
│   │   └── Views/              # Chart views
│   └── Statistics/             # Statistics module
│       ├── Model/              # Statistics models
│       ├── ViewModel/          # Statistics view model
│       └── Views/              # Statistics views
├── TabBar/
│   └── MainTabView.swift       # Main tab navigation
└── Utils/                      # Utility extensions
```

## Usage

### First Launch
1. When you first launch the app, you'll be prompted to grant HealthKit permissions
2. Grant read and write permissions for:
   - Step Count
   - Heart Rate
   - Active Energy Burned
   - Sleep Analysis

### Dashboard
- View your current health metrics at a glance
- Check sync status to ensure data is up to date
- View weekly progress chart
- Access connected devices
- Add manual step entries if needed

### Analytics
- Select a metric (Steps, Heart Rate, Active Energy, or Sleep)
- Choose a time range (1W, 1M, 6M, 1Y)
- Interact with charts to explore your data in detail

### Statistics
- Select a time range (Today, Week, Month, Year)
- View comprehensive statistics for all health metrics
- Track your achievements and personal bests

## HealthKit Permissions

The app requires the following HealthKit permissions:

### Read Permissions
- Step Count
- Heart Rate
- Active Energy Burned
- Sleep Analysis

### Write Permissions
- Step Count (for manual entries)
- Heart Rate
- Active Energy Burned
- Sleep Analysis

### Background Delivery
The app is configured for background delivery to automatically sync health data when new samples are available.

## Technologies

- **SwiftUI**: Modern declarative UI framework
- **HealthKit**: Apple's health data framework
- **DGCharts**: Charting library for data visualization
- **CocoaPods**: Dependency management
- **Combine**: Reactive programming for data flow

## Dependencies

- **DGCharts**: A powerful charting library for iOS, used for creating interactive bar charts and data visualizations

## Background Sync

The app automatically:
- Syncs health data every 15 minutes
- Enables background delivery for step count updates
- Observes HealthKit data changes in real-time

## Device Support

The app can detect and display information about:
- Apple Watch
- iPhone (built-in sensors)
- Third-party fitness trackers
- Other HealthKit-compatible devices

## Privacy

- All health data is stored locally on your device
- Data is only accessed through Apple's HealthKit framework
- No data is transmitted to external servers
- You have full control over which data types to share with the app

## Development

### Code Style
- Follows Swift naming conventions
- Uses MVVM architecture pattern
- Modular structure for easy maintenance

### Key Components
- `HealthKitManager`: Singleton class managing all HealthKit interactions
- Observable objects for reactive UI updates
- Extension-based organization for related functionality

## Troubleshooting

### HealthKit Not Available
- Ensure you're running on a physical iOS device (HealthKit is not available in the simulator)
- Verify HealthKit capability is enabled in your project settings

### No Data Showing
- Check that HealthKit permissions have been granted
- Ensure your device has health data available
- Verify background delivery is enabled

### Build Errors
- Run `pod install` to ensure all dependencies are installed
- Clean build folder: `Cmd + Shift + K`
- Delete derived data if issues persist

## Acknowledgments

- Apple HealthKit framework
- DGCharts library for charting capabilities

---

**Note**: This app requires a physical iOS device to function properly, as HealthKit is not available in the iOS Simulator.
