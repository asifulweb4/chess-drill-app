# ♟️ Chess Drill App

A professional iOS app for chess players to create, practice, and master custom chess drills. Features a fully interactive chess board, comprehensive drill management, and premium subscription integration.

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-4.0-green.svg" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="License">
</p>

## ✨ Features

### Core Functionality
- 🎯 **Interactive Chess Board** - Full 8x8 board with drag-and-drop piece movement
- ✏️ **Drill Management** - Create, Read, Update, Delete (CRUD) custom drills
- 💾 **Data Persistence** - All drills saved locally using UserDefaults
- 🎨 **Beautiful UI** - Modern SwiftUI design with gradient backgrounds

### Premium Features
- 👑 **Subscription Model** - 2 free drills, then $0.99/month for unlimited
- 💳 **Real Payment Integration** - StoreKit 2 implementation
- 🔄 **Auto-Renewal** - Automatic monthly subscription handling
- ✅ **Receipt Validation** - Secure transaction verification

### Chess Features
- ♔ All 12 chess pieces (White & Black: King, Queen, Rook, Bishop, Knight, Pawn)
- 📍 Place pieces on any square
- 🔀 Move pieces by tap selection
- 🗑️ Clear board functionality
- 💡 Practice custom positions

## 📱 Screenshots

*Coming soon - Add screenshots after deployment*

## 🛠️ Technical Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Minimum iOS:** 17.0+
- **Architecture:** MVVM
- **Payment:** StoreKit 2
- **Persistence:** UserDefaults
- **Testing:** StoreKit Configuration File

## 🏗️ Project Structure

```
ChessDrillApp/
├── ChessDrillApp.swift          # App entry point
├── Models.swift                  # Data models (Drill, ChessPiece, Position)
├── DrillManager.swift            # CRUD operations & business logic
├── StoreManager.swift            # StoreKit payment handling
├── ContentView.swift             # Main drill list screen
├── DrillEditorView.swift         # Drill creation/editing
├── ChessBoardView.swift          # Interactive chess board
├── PaywallView.swift             # Subscription paywall
├── Assets.xcassets/              # App icons and images
└── Products.storekit             # StoreKit testing configuration
```

## 🚀 Getting Started

### Prerequisites

- macOS 14.0+ (Sonoma)
- Xcode 15.0+
- Apple Developer Account (for App Store submission)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ChessDrillApp.git
cd ChessDrillApp
```

2. Open in Xcode:
```bash
open ChessDrillApp.xcodeproj
```

3. Update Bundle Identifier:
   - Select project in Xcode
   - Target → Signing & Capabilities
   - Change Bundle ID to your own

4. Update Product ID in `StoreManager.swift`:
```swift
private let productIDs = ["com.YOURBUNDLEID.ChessDrillApp.premium"]
```

5. Run the app:
   - Select a simulator (iPhone 15 Pro recommended)
   - Press Cmd+R or click Run button

## 🧪 Testing

### Testing Subscription Flow

1. **Enable StoreKit Configuration:**
   - Product → Scheme → Edit Scheme
   - Run → Options
   - StoreKit Configuration: Select `Products.storekit`

2. **Test Flow:**
   - Create 2 drills (free tier)
   - Attempt to create 3rd drill
   - Paywall appears
   - Click Subscribe → Confirm
   - Premium unlocked!

### Testing on Real Device

1. Create Sandbox Tester in App Store Connect
2. Sign in on device with sandbox account
3. Test subscription purchase (no real money charged)

## 💰 Monetization

### Pricing Model
- **Free Tier:** 2 drills
- **Premium:** $0.99/month for unlimited drills

### Revenue Split (App Store)
- **First Year:** 70% to developer, 30% to Apple
- **After 1 Year:** 85% to developer, 15% to Apple

## 🔧 Configuration

### StoreKit Setup

1. Create In-App Purchase in App Store Connect:
   - Type: Auto-Renewable Subscription
   - Product ID: `com.YOURBUNDLEID.ChessDrillApp.premium`
   - Price: $0.99/month
   - Duration: 1 Month

2. Add Localization:
   - Display Name: Premium
   - Description: Unlock unlimited chess drills

3. Submit for Review

## 📦 Deployment

### App Store Submission

1. **Archive:**
   - Product → Archive
   - Wait for build to complete

2. **Upload:**
   - Window → Organizer
   - Select archive → Distribute App
   - Follow wizard

3. **Complete App Store Connect:**
   - Screenshots (required)
   - App Description
   - Keywords
   - Privacy Policy
   - Support URL

4. **Submit for Review**

Expected timeline: 2-3 days for review

## 🐛 Known Issues

- StoreKit Configuration may not work in some Xcode versions - use real device testing
- Simulator may require restart for StoreKit to initialize properly

## 🔮 Future Enhancements

- [ ] iCloud sync for drills
- [ ] Share drills with friends
- [ ] Pre-made drill library (famous positions)
- [ ] Move validation (legal chess moves)
- [ ] Move history tracking
- [ ] Drill categories (Opening, Endgame, Tactics)
- [ ] Analytics integration
- [ ] Dark mode optimization
- [ ] iPad support

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Mohammed Asiful Islam**
- GitHub: [@asifulislam](https://github.com/asifulislam)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Chess piece Unicode characters
- StoreKit 2 documentation
- SwiftUI community

## 📞 Support

For support, open an issue in this repository.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

Made with ❤️ for chess players worldwide

⭐ Star this repo if you find it useful!