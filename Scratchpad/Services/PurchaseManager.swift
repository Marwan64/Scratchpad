import StoreKit
import Observation

@Observable
@MainActor
final class PurchaseManager {
    static let widgetProductID = "com.scratchpad.app.widget_unlock"
    private static let unlockKey = "sp_widget_unlocked"

    private(set) var isWidgetUnlocked: Bool = false
    private(set) var widgetProduct: Product? = nil
    private(set) var isPurchasing: Bool = false
    private(set) var purchaseError: String? = nil

    private static let appGroupID = "group.com.scratchpad.app"

    private var defaults: UserDefaults {
        UserDefaults(suiteName: Self.appGroupID) ?? .standard
    }

    init() {
        let ud = UserDefaults(suiteName: Self.appGroupID) ?? .standard
        isWidgetUnlocked = ud.bool(forKey: Self.unlockKey)
        Task {
            await loadProducts()
            await refreshPurchaseStatus()
        }
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.widgetProductID])
            widgetProduct = products.first
        } catch {
            widgetProduct = nil
        }
    }

    func purchase() async {
        guard let product = widgetProduct else { return }
        isPurchasing = true
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshPurchaseStatus()
                await transaction.finish()
            case .pending:
                break
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    func restorePurchases() async {
        isPurchasing = true
        try? await AppStore.sync()
        await refreshPurchaseStatus()
        isPurchasing = false
    }

    func refreshPurchaseStatus() async {
        var found = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let tx) = result else { continue }
            if tx.productID == Self.widgetProductID && tx.revocationDate == nil {
                found = true
            }
        }
        isWidgetUnlocked = found
        defaults.set(found, forKey: Self.unlockKey)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }

    var formattedPrice: String {
        widgetProduct?.displayPrice ?? "$1.99"
    }
}
