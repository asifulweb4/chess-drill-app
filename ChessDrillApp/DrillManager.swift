import Foundation
import SwiftUI
import Combine

class DrillManager: ObservableObject {
    @Published var drills: [Drill] = []
    
    // Reference to StoreManager for checking premium status
    weak var storeManager: StoreManager?
    
    private let maxFreeDrills = 2
    private let drillsKey = "saved_drills"
    
    init() {
        loadDrills()
    }
    
    // CRUD Operations
    
    func createDrill(_ drill: Drill) {
        drills.append(drill)
        saveDrills()
    }
    
    func importDrill(jsonString: String) {
        guard let data = jsonString.data(using: .utf8),
              let drill = try? JSONDecoder().decode(Drill.self, from: data) else {
            return
        }
        
        // Ensure ID is unique if importing a duplicate
        var importedDrill = drill
        if drills.contains(where: { $0.id == drill.id }) {
            // If it already exists, maybe we update it or create a copy with a new ID
            // For now, let's treat it as a new copy if it's imported
            importedDrill = Drill(name: drill.name + " (Imported)", description: drill.description, pieces: drill.pieces)
        }
        
        createDrill(importedDrill)
    }
    
    func updateDrill(_ drill: Drill) {
        if let index = drills.firstIndex(where: { $0.id == drill.id }) {
            drills[index] = drill
            saveDrills()
        }
    }
    
    func deleteDrill(_ drill: Drill) {
        drills.removeAll { $0.id == drill.id }
        saveDrills()
    }
    
    func getDrill(id: UUID) -> Drill? {
        drills.first { $0.id == id }
    }
    
    // Payment Logic
    
    func canCreateNewDrill() -> Bool {
        let isPremium = storeManager?.isPremium ?? false
        return isPremium || drills.count < maxFreeDrills
    }
    
    func shouldShowPaywall() -> Bool {
        let isPremium = storeManager?.isPremium ?? false
        return !isPremium && drills.count >= maxFreeDrills
    }
    
    // Persistence
    
    private func saveDrills() {
        if let encoded = try? JSONEncoder().encode(drills) {
            UserDefaults.standard.set(encoded, forKey: drillsKey)
        }
    }
    
    private func loadDrills() {
        if let data = UserDefaults.standard.data(forKey: drillsKey),
           let decoded = try? JSONDecoder().decode([Drill].self, from: data) {
            drills = decoded
        }
    }
}
