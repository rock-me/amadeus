import StoreKit
import Player
import Combine

final class Purchases: NSObject, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private(set) var products = CurrentValueSubject<[SKProduct], Never>([])
    private(set) var error = PassthroughSubject<String, Never>()
    private weak var request: SKProductsRequest?
    
    func load() {
        SKPaymentQueue.default().add(self)

        let request = SKProductsRequest(productIdentifiers: .init(Album.allCases.map(\.purchase)))
        request.delegate = self
        self.request = request
        request.start()
    }
    
    deinit {
        request?.cancel()
        SKPaymentQueue.default().remove(self)
    }
    
    func productsRequest(_: SKProductsRequest, didReceive: SKProductsResponse) {
        products.value = didReceive.products
    }
    
    func paymentQueue(_: SKPaymentQueue, updatedTransactions: [SKPaymentTransaction]) {
        update(updatedTransactions)
    }
    
    func paymentQueue(_: SKPaymentQueue, removedTransactions: [SKPaymentTransaction]) {
        update(removedTransactions)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) {
        products.send(products.value)
    }
    
    func request(_: SKRequest, didFailWithError: Error) {
        error.send(didFailWithError.localizedDescription)
    }
    
    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {
        error.send(restoreCompletedTransactionsFailedWithError.localizedDescription)
    }
    
    private func update(_ transactions: [SKPaymentTransaction]) {
        guard !transactions.contains(where: { $0.transactionState == .purchasing }) else { return }
        transactions.forEach {
            switch $0.transactionState {
            case .failed:
                SKPaymentQueue.default().finishTransaction($0)
            case .restored, .purchased:
                session.player.config.value.purchases.insert($0.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction($0)
            default:
                break
            }
        }
        products.send(products.value)
    }
    
    func purchase(_ product: SKProduct) {
        SKPaymentQueue.default().add(.init(product: product))
    }
    
    @objc func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
