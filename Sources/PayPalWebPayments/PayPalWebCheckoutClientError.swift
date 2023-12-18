import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

enum PayPalWebCheckoutClientError {

    static let domain = "PayPalClientErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. An error occurred during web authentication session.
        case webSessionError

        /// 2. Error constructing PayPal URL.
        case payPalURLError

        /// 3. Result did not contain the expected data.
        case malformedResultError

        /// 4. Vault result did not return a token id
        case paypalVaultResponseError
    }

    static let webSessionError: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.webSessionError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }

    static let payPalURLError = CoreSDKError(
        code: Code.payPalURLError.rawValue,
        domain: domain,
        errorDescription: "Error constructing URL for PayPal request."
    )

    static let malformedResultError = CoreSDKError(
        code: Code.malformedResultError.rawValue,
        domain: domain,
        errorDescription: "Result did not contain the expected data."
    )

    static let payPalVaultResponseError = CoreSDKError(
        code: Code.paypalVaultResponseError.rawValue,
        domain: domain,
        errorDescription: "Error parsing paypal vault response"
    )
}
