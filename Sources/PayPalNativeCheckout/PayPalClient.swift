import UIKit

@_implementationOnly import PayPalCheckout

#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    public weak var delegate: PayPalDelegate?

    private let apiClient: APIClient
    private let config: CoreConfig

    // swiftlint:disable identifier_name
    private let CheckoutFlow: CheckoutProtocol.Type
    // swiftlint:enable identifier_name

    /// Initialize a PayPalClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    public convenience init(config: CoreConfig) {
        self.init(
            config: config,
            checkoutFlow: Checkout.self,
            apiClient: APIClient(coreConfig: config)
        )
    }

    init(config: CoreConfig, checkoutFlow: CheckoutProtocol.Type, apiClient: APIClient) {
        self.config = config
        self.CheckoutFlow = checkoutFlow
        self.apiClient = apiClient
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    ///   - completion: Completion block to handle buyer's approval, cancellation, and error.
    public func start(request: PayPalRequest, presentingViewController: UIViewController? = nil) async {
        do {
            let clientID = try await apiClient.getClientID()
            DispatchQueue.main.async {
                self.configureAndStartCheckout(
                    withClientID: clientID,
                    request: request,
                    presentingViewController: presentingViewController
                )
            }
        } catch {
            delegate?.paypal(self, didFinishWithError: PayPalError.clientIDNotFoundError(error))
        }
    }

    private func configureAndStartCheckout(
        withClientID clientID: String,
        request: PayPalRequest,
        presentingViewController: UIViewController?
    ) {
        CheckoutFlow.set(config: config, clientID: clientID)
        CheckoutFlow.start(
            presentingViewController: presentingViewController,
            createOrder: { order in
                order.set(orderId: request.orderID)
            },
            onApprove: { approval in
                self.notifySuccess(for: approval)
            },
            onCancel: {
                self.notifyCancellation()
            },
            onError: { errorInfo in
                self.notifyFailure(with: errorInfo)
            }
        )
    }

    private func notifySuccess(for approval: PayPalCheckoutApprovalData) {
        let payPalResult = PayPalResult(orderID: approval.ecToken, payerID: approval.payerID)
        delegate?.paypal(self, didFinishWithResult: payPalResult)
    }

    private func notifyFailure(with errorInfo: PayPalCheckoutErrorInfo) {
        let error = PayPalError.nativeCheckoutSDKError(errorInfo)
        delegate?.paypal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        delegate?.paypalDidCancel(self)
    }
}
