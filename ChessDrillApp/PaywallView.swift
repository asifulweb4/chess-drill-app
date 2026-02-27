import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var drillManager: DrillManager
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                // Title
                Text("Unlock Unlimited Drills")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Description
                Text("You've created 2 free drills.\nUpgrade to create unlimited drills and improve your chess skills!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Features
                VStack(alignment: .leading, spacing: 15) {
                    featureRow(icon: "infinity", text: "Unlimited drills")
                    featureRow(icon: "square.and.pencil", text: "Create custom positions")
                    featureRow(icon: "chart.line.uptrend.xyaxis", text: "Improve your chess")
                    featureRow(icon: "arrow.clockwise", text: "Practice anytime")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Price and subscription button
                if storeManager.isLoading {
                    VStack(spacing: 15) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Loading...")
                            .foregroundColor(.white)
                    }
                } else if let product = storeManager.subscriptions.first {
                    VStack(spacing: 10) {
                        Text(getProductPrice(product) + " / " + storeManager.subscriptionDuration(for: product))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Cancel anytime")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Subscribe button
                    Button(action: {
                        Task {
                            await subscribeToPremium(product)
                        }
                    }) {
                        if storeManager.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Subscribe Now")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    .disabled(storeManager.isPurchasing)
                } else {
                    // Error state
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                        Text("Unable to load products")
                            .foregroundColor(.white)
                    }
                }
                
                // Error message
                if let error = storeManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                }
                
                // Restore purchases
                Button(action: {
                    Task {
                        await restorePurchases()
                    }
                }) {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .disabled(storeManager.isPurchasing)
                
                Spacer()
            }
        }
        .onChange(of: storeManager.isPremium) { _, isPremium in
            if isPremium {
                dismiss()
            }
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    private func subscribeToPremium(_ product: Any) async {
        do {
            _ = try await storeManager.purchase(product)
        } catch {
            print("Purchase error: \(error)")
        }
    }
    
    private func restorePurchases() async {
        await storeManager.restorePurchases()
    }
    
    private func getProductPrice(_ product: Any) -> String {
        if let storeKitProduct = product as? Product {
            return storeKitProduct.displayPrice
        } else if let mockProduct = product as? MockProduct {
            return mockProduct.displayPrice
        }
        return "$0.99"
    }
}
