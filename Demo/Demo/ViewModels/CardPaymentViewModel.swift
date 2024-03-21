import Foundation
import CardPayments
import CorePayments
import FraudProtection

class CardPaymentViewModel: ObservableObject, CardDelegate {

    @Published var state = CardPaymentState()
    private var payPalDataCollector: PayPalDataCollector?

    let configManager = CoreConfigManager(domain: "Card Payments")

    private var cardClient: CardClient?

    func createOrder(
        amount: String,
        selectedMerchantIntegration: MerchantIntegration,
        intent: String,
        shouldVault: Bool,
        customerID: String? = nil
    ) async throws {

        let amountRequest = Amount(currencyCode: "USD", value: amount)
        // TODO: might need to pass in payee as payee object or as auth header

        var vaultCardPaymentSource: VaultCardPaymentSource?
        if shouldVault {
            var customer: Customer?
            if let customerID {
                customer = Customer(id: customerID)
            }
            let attributes = Attributes(vault: Vault(storeInVault: "ON_SUCCESS"), customer: customer)
            let card = VaultCard(attributes: attributes)
            vaultCardPaymentSource = VaultCardPaymentSource(card: card)
        }

        var vaultPaymentSource: VaultPaymentSource?
        if let vaultCardPaymentSource {
            vaultPaymentSource = .card(vaultCardPaymentSource)
        }

        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: intent,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: vaultPaymentSource
        )

        do {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams, selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loaded(order)
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            }
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }

    func captureOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loading
            }
            let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
            let order = try await DemoMerchantAPI.sharedService.captureOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                payPalClientMetadataID: payPalClientMetadataID
            )
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func authorizeOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loading
            }
            let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
            let order = try await DemoMerchantAPI.sharedService.authorizeOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                payPalClientMetadataID: payPalClientMetadataID
            )
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func checkoutWith(card: Card, orderID: String, sca: SCA) async {
        do {
            DispatchQueue.main.async {
                self.state.approveResultResponse = .loading
            }
            let config = try await configManager.getCoreConfig()
            cardClient = CardClient(config: config)
            payPalDataCollector = PayPalDataCollector(config: config)
            cardClient?.delegate = self
            let cardRequest = CardRequest(orderID: orderID, card: card, sca: sca)
            cardClient?.approveOrder(request: cardRequest)
        } catch {
            self.state.approveResultResponse = .error(message: error.localizedDescription)
            print("failed in checkout with card. \(error.localizedDescription)")
        }
    }

    func approveResultSuccessResult(approveResult: CardPaymentState.CardResult) {
        DispatchQueue.main.async {
            self.state.approveResultResponse = .loaded(
                approveResult
            )
        }
    }

    func setUpdateSetupTokenFailureResult(vaultError: CorePayments.CoreSDKError) {
        DispatchQueue.main.async {
            self.state.approveResultResponse = .error(message: vaultError.localizedDescription)
        }
    }

    // MARK: - Card Delegate

    func card(_ cardClient: CardPayments.CardClient, didFinishWithResult result: CardPayments.CardResult) {
        approveResultSuccessResult(
            approveResult: CardPaymentState.CardResult(
                id: result.orderID,
                status: result.status,
                didAttemptThreeDSecureAuthentication: result.didAttemptThreeDSecureAuthentication
            )
        )
    }

    func card(_ cardClient: CardPayments.CardClient, didFinishWithError error: CorePayments.CoreSDKError) {
        print("Error here")
        DispatchQueue.main.async {
            self.state.approveResultResponse = .error(message: error.localizedDescription)
        }
    }

    func cardDidCancel(_ cardClient: CardPayments.CardClient) {
        print("Card Payment Canceled")
        DispatchQueue.main.async {
            self.state.approveResultResponse = .idle
            self.state.approveResult = nil
        }
    }

    func cardThreeDSecureWillLaunch(_ cardClient: CardPayments.CardClient) {
        print("About to launch 3DS")
    }

    func cardThreeDSecureDidFinish(_ cardClient: CardPayments.CardClient) {
        print("Finished 3DS")
    }
}
