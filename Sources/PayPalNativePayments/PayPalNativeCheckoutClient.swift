import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

/// PayPal Paysheet to handle PayPal transaction
/// encapsulates instance to communicate with nxo
public class PayPalNativeCheckoutClient {

    public weak var delegate: PayPalNativeCheckoutDelegate?
    public weak var shippingDelegate: PayPalNativeShippingDelegate?
    private let nativeCheckoutProvider: NativeCheckoutStartable
    private let apiClient: APIClient
    private let config: CoreConfig
    private var analyticsService: AnalyticsService?

    /// Initialize a PayPalNativeCheckoutClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    public convenience init(config: CoreConfig) {
        self.init(
            config: config,
            nativeCheckoutProvider: NativeCheckoutProvider(),
            apiClient: APIClient(coreConfig: config)
        )
    }

    init(config: CoreConfig, nativeCheckoutProvider: NativeCheckoutStartable, apiClient: APIClient) {
        self.config = config
        self.nativeCheckoutProvider = nativeCheckoutProvider
        self.apiClient = apiClient
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - request: The PayPalNativeCheckoutRequest for the transaction
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    public func start(
        request: PayPalNativeCheckoutRequest,
        presentingViewController: UIViewController? = nil
    ) async {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        
        let nxoConfig = CheckoutConfig(
            clientID: config.clientID,
            createOrder: nil,
            onApprove: nil,
            onShippingChange: nil,
            onCancel: nil,
            onError: nil,
            environment: config.environment.toNativeCheckoutSDKEnvironment()
        )
        delegate?.paypalWillStart(self)
        
        analyticsService?.sendEvent("paypal-native-payments:started")
        self.nativeCheckoutProvider.start(
            presentingViewController: presentingViewController,
            orderID: request.orderID,
            onStartableApprove: { ecToken, payerID in
                let result = PayPalNativeCheckoutResult(
                    orderID: ecToken,
                    payerID: payerID
                )
                self.notifySuccess(for: result)
            },
            onStartableShippingChange: { shippingType, shippingAction, shippingAddress, shippingMethod in
                switch shippingType {
                case .shippingAddress:
                    self.notifyShippingChange(shippingActions: shippingAction, shippingAddress: shippingAddress)
                case .shippingMethod:
                    guard let selectedShippingMethod = shippingMethod else {
                        return
                    }
                    self.notifyShippingMethod(
                        shippingActions: shippingAction,
                        shippingMethod: selectedShippingMethod
                    )
                @unknown default:
                    break // do nothing
                }
            },
            onStartableCancel: {
                self.notifyCancellation()
            },
            onStartableError: { errorReason in
                self.notifyFailure(with: errorReason)
            },
            nxoConfig: nxoConfig
        )
    }
    
    private func notifySuccess(for result: PayPalNativeCheckoutResult) {
        analyticsService?.sendEvent("paypal-native-payments:succeeded")
        delegate?.paypal(self, didFinishWithResult: result)
    }

    private func notifyFailure(with errorDescription: String) {
        analyticsService?.sendEvent("paypal-native-payments:failed")
        
        let error = PayPalNativePaymentsError.nativeCheckoutSDKError(errorDescription)
        delegate?.paypal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        analyticsService?.sendEvent("paypal-native-payments:canceled")
        delegate?.paypalDidCancel(self)
    }
    
    private func notifyShippingMethod(
        shippingActions: PayPalNativePaysheetActions,
        shippingMethod: PayPalNativeShippingMethod
    ) {
        analyticsService?.sendEvent("paypal-native-payments:shipping-method-changed")
        shippingDelegate?.paypal(self, didShippingMethodChange: shippingMethod, withAction: shippingActions)
    }
    
    private func notifyShippingChange(
        shippingActions: PayPalNativePaysheetActions,
        shippingAddress: PayPalNativeShippingAddress
    ) {
        analyticsService?.sendEvent("paypal-native-payments:shipping-address-changed")
        shippingDelegate?.paypal(self, didShippingAddressChange: shippingAddress, withAction: shippingActions)
    }
}
