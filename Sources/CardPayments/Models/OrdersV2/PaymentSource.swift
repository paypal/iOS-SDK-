import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

public struct PaymentSource: Decodable {

    /// The card used as payment
    public let card: PaymentSource.Card

    public struct Card: Decodable {

        /// The last four digits of the provided card
        public let lastFourDigits: String?

        /// The card network
        /// - Examples: "VISA", "MASTERCARD"
        public let brand: String?

        /// The type of the provided card.
        /// - Examples: "DEBIT", "CREDIT"
        public let type: String?

        /// The result of the 3DS challenge
        public let authenticationResult: AuthenticationResult?
    }
}
