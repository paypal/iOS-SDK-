import Foundation
import CardPayments
import CorePayments

class CardVaultViewModel: VaultViewModel, CardVaultDelegate {

    let configManager = CoreConfigManager(domain: "Card Vault")

    func vault(card: Card, setupToken: String) async {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .loading
        }
        do {
            let config = try await configManager.getCoreConfig()
            let cardClient = CardClient(config: config)
            cardClient.vaultDelegate = self
            let cardVaultRequest = CardVaultRequest(card: card, setupTokenID: setupToken)
            cardClient.vault(cardVaultRequest)
        } catch {
            self.state.updateSetupTokenResponse = .error(message: error.localizedDescription)
            print("failed in updating setup token. \(error.localizedDescription)")
        }
    }

    func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }

    func setUpdateTokenSuccessResult(vaultResult: CardPayments.CardVaultResult) {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .loaded(
                UpdateSetupTokenResult(
                    id: vaultResult.setupTokenID,
                    status: vaultResult.status,
                    threeDSecureAttempted: vaultResult.threeDSecureAttempted
                )
            )
        }
    }

    func setUpdateSetupTokenFailureResult(vaultError: CorePayments.CoreSDKError) {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .error(message: vaultError.localizedDescription)
        }
    }

    // MARK: - CardVault Delegate

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultResult vaultResult: CardPayments.CardVaultResult) {
        print("vaultResult: \(vaultResult)")
        setUpdateTokenSuccessResult(vaultResult: vaultResult)
    }

    func card(_ cardClient: CardPayments.CardClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        print("error: \(vaultError.errorDescription ?? "")")
        setUpdateSetupTokenFailureResult(vaultError: vaultError)
    }

    func cardVaultDidCancel(_ cardClient: CardClient) {
        DispatchQueue.main.async {
            self.state.updateSetupTokenResponse = .idle
            self.state.updateSetupToken = nil
        }
    }

    func cardThreeDSecureWillLaunch(_ cardClient: CardPayments.CardClient) {
        print("About to launch 3DS")
    }

    func cardThreeDSecureDidFinish(_ cardClient: CardPayments.CardClient) {
        print("Finished 3DS")
    }
}
