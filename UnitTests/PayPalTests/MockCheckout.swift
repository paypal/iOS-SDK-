import Foundation
import UIKit

@testable import PayPal
@testable import PaymentsCore

class MockCheckout: PayPalUIFlow {
    static var onApprove: ApprovalCallback?
    static var onCancel: CancelCallback?
    static var onError: ErrorCallback?

    static func set(config: CoreConfig, returnURL: String) {
        
    }

    static func start(
        presentingViewController: UIViewController?,
        createOrder: CreateOrderCallback?,
        onApprove: ApprovalCallback?,
        onCancel: CancelCallback?,
        onError: ErrorCallback?
    ) {
        self.onApprove = onApprove
        self.onCancel = onCancel
        self.onError = onError
    }

    static func triggerApproval(approval: MockApproval) {
        onApprove?(approval)
    }

    static func triggerCancel() {
        onCancel?()
    }

    static func triggerError(error: PayPalCheckoutErrorInfo) {
        onError?(error)
    }
}

struct MockApproval: PayPalCheckoutApprovalData {
    var intent: String
    var payerID: String
    var ecToken: String
}

struct MockPayPalError: PayPalCheckoutErrorInfo {
    var reason: String
    var error: Error
}
