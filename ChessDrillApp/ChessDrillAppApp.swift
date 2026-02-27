import SwiftUI

@main
struct ChessDrillApp: App {
    @StateObject private var storeManager = StoreManager()
    @StateObject private var drillManager: DrillManager
    
    init() {
        // Initialize DrillManager
        let manager = DrillManager()
        _drillManager = StateObject(wrappedValue: manager)
        
        // Connect StoreManager after initialization
        // This will be done in the body using onAppear
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(drillManager)
                .environmentObject(storeManager)
                .onAppear {
                    // Connect managers after view appears
                    drillManager.storeManager = storeManager
                }
        }
    }
}
