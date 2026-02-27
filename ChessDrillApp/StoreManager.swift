import StoreKit
import SwiftUI
import Combine

@MainActor
final class StoreManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var products: [StoreKit.Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published var isPremium: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    // MARK: - Properties
    private let productIDs = ["com.asiful.ChessDrillApp.premium"]
    private var updates: Task<Void, Never>?
    
    // Mock product for testing when StoreKit fails
    private var mockProduct: MockProduct?
    
    // MARK: - Computed Properties
    var subscriptions: [Any] {
        if !products.isEmpty {
            return products
        } else if let mock = mockProduct {
            return [mock]
        }
        return []
    }
    
    // MARK: - Initialization
    init() {
        updates = observeTransactionUpdates()
        
        // Create mock product as fallback
        mockProduct = MockProduct(
            id: "com.asiful.ChessDrillApp.premium",
            displayName: "Premium",
            displayPrice: "$0.99",
            description: "Monthly subscription"
        )
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Transaction Updates
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in StoreKit.Transaction.updates {
                await self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<StoreKit.Transaction>) async {
        guard case .verified(let transaction) = verificationResult else {
            return
        }
        
        await transaction.finish()
        await updatePurchasedProducts()
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        self.isLoading = true
        self.errorMessage = nil
        
        print("🔍 StoreManager: Starting to load products for IDs: \(productIDs)")
        
        do {
            let loadedProducts = try await StoreKit.Product.products(for: productIDs)
            
            if !loadedProducts.isEmpty {
                self.products = loadedProducts
                print("✅ StoreManager: Successfully loaded \(loadedProducts.count) products")
                for product in loadedProducts {
                    print("   - Product: \(product.id), Price: \(product.displayPrice)")
                }
            } else {
                print("⚠️ StoreManager: No products loaded from StoreKit")
                print("   Using mock product for testing")
                // Mock product already set in init
            }
        } catch {
            print("❌ StoreManager: Loading error: \(error)")
            print("   Using mock product for testing")
            // Mock product already set in init
        }
        
        self.isLoading = false
    }
    
    // MARK: - Purchase
    func purchase(_ product: Any) async throws -> Bool {
        self.isPurchasing = true
        self.errorMessage = nil
        
        defer {
            self.isPurchasing = false
        }
        
        // Handle real StoreKit product
        if let storeKitProduct = product as? StoreKit.Product {
            do {
                let result = try await storeKitProduct.purchase()
                
                switch result {
                case .success(let verificationResult):
                    switch verificationResult {
                    case .verified(let transaction):
                        await transaction.finish()
                        await updatePurchasedProducts()
                        return true
                        
                    case .unverified:
                        self.errorMessage = "Transaction could not be verified"
                        return false
                    }
                    
                case .userCancelled:
                    return false
                    
                case .pending:
                    self.errorMessage = "Purchase is pending"
                    return false
                    
                @unknown default:
                    return false
                }
            } catch {
                self.errorMessage = error.localizedDescription
                throw error
            }
        }
        
        // Handle mock product for testing
        if product is MockProduct {
            print("🧪 Mock purchase - simulating success")
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Unlock premium
            self.isPremium = true
            
            // Save to UserDefaults for persistence
            UserDefaults.standard.set(true, forKey: "mock_premium")
            
            return true
        }
        
        return false
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        self.isPurchasing = true
        self.errorMessage = nil
        
        defer {
            self.isPurchasing = false
        }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            
            // Also check mock premium
            if UserDefaults.standard.bool(forKey: "mock_premium") {
                self.isPremium = true
            }
        } catch {
            self.errorMessage = "Failed to restore: \(error.localizedDescription)"
            
            // Check mock premium on error too
            if UserDefaults.standard.bool(forKey: "mock_premium") {
                self.isPremium = true
            }
        }
    }
    
    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
        
        // Check both real and mock premium
        let hasMockPremium = UserDefaults.standard.bool(forKey: "mock_premium")
        self.isPremium = !purchasedIDs.isEmpty || hasMockPremium
        
        print(isPremium ? "✅ Premium active" : "ℹ️ No premium")
    }
    
    // MARK: - Helper Methods
    func subscriptionDuration(for product: Any) -> String {
        if let storeKitProduct = product as? StoreKit.Product,
           let subscription = storeKitProduct.subscription {
            let unit = subscription.subscriptionPeriod.unit
            let value = subscription.subscriptionPeriod.value
            
            if value == 1 {
                switch unit {
                case .day: return "Daily"
                case .week: return "Weekly"
                case .month: return "Monthly"
                case .year: return "Yearly"
                @unknown default: return ""
                }
            } else {
                switch unit {
                case .day: return "\(value) Days"
                case .week: return "\(value) Weeks"
                case .month: return "\(value) Months"
                case .year: return "\(value) Years"
                @unknown default: return ""
                }
            }
        }
        
        // Mock product
        return "Monthly"
    }
}

// MARK: - Mock Product
struct MockProduct: Identifiable {
    let id: String
    let displayName: String
    let displayPrice: String
    let description: String
}
