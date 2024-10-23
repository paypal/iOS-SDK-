import Foundation
import AuthenticationServices
#if canImport(CorePayments)
import CorePayments
#endif

public class CardClient: NSObject {
    
    private let checkoutOrdersAPI: CheckoutOrdersAPI
    private let vaultAPI: VaultPaymentTokensAPI
    
    private let config: CoreConfig
    private let webAuthenticationSession: WebAuthenticationSession
    private var analyticsService: AnalyticsService?

    /// Initialize a CardClient to process card payment
    /// - Parameter config: The CoreConfig object
    public init(config: CoreConfig) {
        self.config = config
        self.checkoutOrdersAPI = CheckoutOrdersAPI(coreConfig: config)
        self.vaultAPI = VaultPaymentTokensAPI(coreConfig: config)
        self.webAuthenticationSession = WebAuthenticationSession()
    }

    /// For internal use for testing/mocking purpose
    init(
        config: CoreConfig,
        checkoutOrdersAPI: CheckoutOrdersAPI,
        vaultAPI: VaultPaymentTokensAPI,
        webAuthenticationSession: WebAuthenticationSession
    ) {
        self.config = config
        self.checkoutOrdersAPI = checkoutOrdersAPI
        self.vaultAPI = vaultAPI
        self.webAuthenticationSession = webAuthenticationSession
    }

    /// Updates a setup token with a payment method. Performs
    /// 3DS verification if required. If verification is performed, SDK returns a property `didAttemptThreeDSecureAuthentication`.
    /// If `didAttempt3DSecureVerification` is `true`, check verification status with `/v3/vault/setup-token/{id}` in your server.
    /// - Parameters:
    ///   - vaultRequest: The request containing setupTokenID and card
    /// - Returns: A `CardVaultResult` with `setupTokenID` and status of the vault
    /// - Throws: An `Error` describing the failure
    public func vault(_ vaultRequest: CardVaultRequest) async throws -> CardVaultResult {
        analyticsService = AnalyticsService(coreConfig: config, setupToken: vaultRequest.setupTokenID)
        analyticsService?.sendEvent("card-payments:vault-wo-purchase:started")
        do {
            let result = try await vaultAPI.updateSetupToken(cardVaultRequest: vaultRequest).updateVaultSetupToken

            if result.status == "PAYER_ACTION_REQUIRED",
            let urlString = result.links.first(where: { $0.rel == "approve" })?.href {
                guard urlString.contains("helios"), let url = URL(string: urlString) else {
                    analyticsService?.sendEvent("card-payments:vault-wo-purchase:failed")
                    throw CardClientError.threeDSecureURLError
                }
                analyticsService?.sendEvent("card-payments:vault-wo-purchase:challenge-required")
                let cardVaultResult = try await startVaultThreeDSecureChallenge(url: url, setupTokenID: vaultRequest.setupTokenID)
                return cardVaultResult
            } else {
                let vaultResult = CardVaultResult(setupTokenID: result.id, status: result.status, didAttemptThreeDSecureAuthentication: false)
                analyticsService?.sendEvent("card-payments:vault-wo-purchase:succeeded")
                return vaultResult
            }
        } catch let error as CoreSDKError {
            analyticsService?.sendEvent("card-payments:vault-wo-purchase:failed")
            throw error
        } catch {
            analyticsService?.sendEvent("card-payments:vault-wo-purchase:failed")
            throw CardClientError.vaultTokenError
        }
    }

    /// Updates a setup token with a payment method. Performs
    /// 3DS verification if required. If verification is performed, SDK returns a property `didAttemptThreeDSecureAuthentication`.
    /// If `didAttempt3DSecureVerification` is `true`, check verification status with `/v3/vault/setup-token/{id}` in your server.
    /// - Parameters:
    ///   - vaultRequest: The request containing setupTokenID and card
    ///   -  completion: A completion block that is invoked when the request is completed. If the request succeeds,
    ///   a `cardVaultResult` with `setupTokenID` and status of the vault is returned  and `error` will be `nil`;
    ///   if it fails, `cardVaultResult` will be `nil` and `error` will describe the failure
    public func vault(_ vaultRequest: CardVaultRequest, completion: @escaping (CardVaultResult?, Error?) -> Void) {
        Task {
            do {
                let result = try await vault(vaultRequest)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Approve an order with a card, which validates buyer's card, and if valid, attaches the card as the payment source to the order.
    /// After the order has been successfully approved, you will need to handle capturing/authorizing the order in your server.
    /// - Parameters:
    ///   - orderId: Order id for approval
    ///   - request: The request containing the card
    /// - Returns: A `CardResult` with `orderID` and status of the approval
    /// - Throws: An `Error` describing the failure
    public func approveOrder(request: CardRequest) async throws -> CardResult {
        analyticsService = AnalyticsService(coreConfig: config, orderID: request.orderID)
        analyticsService?.sendEvent("card-payments:3ds:started")
        do {
            let result = try await checkoutOrdersAPI.confirmPaymentSource(cardRequest: request)

            if result.status == "PAYER_ACTION_REQUIRED",
            let url = result.links?.first(where: { $0.rel == "payer-action" })?.href {
                guard getQueryStringParameter(url: url, param: "flow") == "3ds",
                    url.contains("helios"),
                    let url = URL(string: url) else {
                    analyticsService?.sendEvent("card-payments:3ds:failed")
                    throw CardClientError.threeDSecureURLError
                }

                analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:challenge-required")
                let cardResult = try await startThreeDSecureChallenge(url: url, orderId: result.id)
                return cardResult
            } else {
                analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:succeeded")

                let cardResult = CardResult(orderID: result.id, status: result.status, didAttemptThreeDSecureAuthentication: false)
                return cardResult
            }
        } catch let error as CoreSDKError {
            analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:failed")
            throw error
        } catch {
            analyticsService?.sendEvent("card-payments:3ds:confirm-payment-source:failed")
            throw CardClientError.unknownError
        }
    }

    /// Approve an order with a card, which validates buyer's card, and if valid, attaches the card as the payment source to the order.
    /// After the order has been successfully approved, you will need to handle capturing/authorizing the order in your server.
    /// - Parameters:
    ///   - orderId: Order id for approval
    ///   - request: The request containing the card
    ///   - completion: A completion block that is invoked when the request is completed. If the request succeeds,
    ///   a `cardResult` with `orderID` and `payerID` are returned and `error` will be `nil`;
    ///   if it fails, `cardResult` will be `nil` and `error` will describe the failure
    public func approveOrder(request: CardRequest, completion: @escaping (CardResult?, Error?) -> Void ) {
        Task {
            do {
                let result = try await approveOrder(request: request)
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    private func startThreeDSecureChallenge(
        url: URL,
        orderId: String
    ) async throws -> CardResult {
        return try await withCheckedThrowingContinuation { continuation in
            webAuthenticationSession.start(
                url: url,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    if didDisplay {
                        self?.analyticsService?.sendEvent("card-payments:3ds:challenge-presentation:succeeded")
                    } else {
                        self?.analyticsService?.sendEvent("card-payments:3ds:challenge-presentation:failed")
                    }
                },
                sessionDidComplete: { _, error in
                    if let error = error {
                        switch error {
                        case ASWebAuthenticationSessionError.canceledLogin:
                            self.analyticsService?.sendEvent("card-payments:3ds:challenge:user-canceled")
                            continuation.resume(throwing: CardClientError.threeDSecureCancellation)
                            return
                        default:
                            self.analyticsService?.sendEvent("card-payments:3ds:failed")
                            continuation.resume(throwing: CardClientError.threeDSecureError(error))
                            return
                        }
                    }

                    let cardResult = CardResult(orderID: orderId, status: nil, didAttemptThreeDSecureAuthentication: true)
                    self.analyticsService?.sendEvent("card-payments:3ds:succeeded")
                    continuation.resume(returning: cardResult)
                }
            )
        }
    }

    private func startVaultThreeDSecureChallenge(
        url: URL,
        setupTokenID: String
    ) async throws -> CardVaultResult {
        return try await withCheckedThrowingContinuation { continuation in
            webAuthenticationSession.start(
                url: url,
                context: self,
                sessionDidDisplay: { [weak self] didDisplay in
                    if didDisplay {
                        self?.analyticsService?.sendEvent("card-payments:3ds:challenge-presentation:succeeded")
                    } else {
                        self?.analyticsService?.sendEvent("card-payments:3ds:challenge-presentation:failed")
                    }
                },
                sessionDidComplete: { _, error in
                    if let error = error {
                        switch error {
                        case ASWebAuthenticationSessionError.canceledLogin:
                            self.analyticsService?.sendEvent("card-payments:3ds:challenge:user-canceled")
                            continuation.resume(throwing: CardClientError.threeDSecureCancellation)
                            return
                        default:
                            self.analyticsService?.sendEvent("card-payments:3ds:failed")
                            continuation.resume(throwing: CardClientError.threeDSecureError(error))
                            return
                        }
                    }

                    let cardVaultResult = CardVaultResult(
                        setupTokenID: setupTokenID,
                        status: nil,
                        didAttemptThreeDSecureAuthentication: true
                    )
                    self.analyticsService?.sendEvent("card-payments:3ds:succeeded")
                    continuation.resume(returning: cardVaultResult)
                }
            )
        }
    }


    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding conformance

extension CardClient: ASWebAuthenticationPresentationContextProviding {

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15, *) {
            let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = firstScene?.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        } else {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            return window ?? ASPresentationAnchor()
        }
    }
}
