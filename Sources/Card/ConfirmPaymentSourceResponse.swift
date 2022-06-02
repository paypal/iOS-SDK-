// swiftlint:disable space_after_main_type

import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// tool used:  https://app.quicktype.io/#l=swift
struct ConfirmPaymentSourceResponse: Decodable {
    let id, status: String
    let paymentSource: PaymentSource?
    let links: [Link]?
}
