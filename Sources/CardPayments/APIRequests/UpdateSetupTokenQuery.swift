import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

class UpdateSetupTokenQuery: Codable, GraphQLQuery {
    
    struct VaultCard: Codable {
        
        public let number: String
        public let expiry: String
        public let securityCode: String
        public let name: String?
        public let billingAddress: Address?
        
        init(number: String, expiry: String, securityCode: String, name: String? = nil, billingAddress: Address? = nil) {
            self.number = number
            self.expiry = expiry
            self.securityCode = securityCode
            self.name = name
            self.billingAddress = billingAddress
        }
    }
    
    struct PaymentSource: Codable {
        
        let card: VaultCard
    }
    
    struct Variables: Codable {
        
        let clientID: String
        let vaultSetupToken: String
        let paymentSource: PaymentSource
    }
    
    var query: String
    var variables: Variables?
    
    init(
        clientID: String,
        vaultSetupToken: String,
        card: Card
    ) {
        let vaultCard = VaultCard(
            number: card.number,
            expiry: card.expiry,
            securityCode: card.securityCode,
            name: card.cardholderName,
            billingAddress: card.billingAddress
        )
        
        let paymentSource = PaymentSource(card: vaultCard)
        
        self.variables = Variables(
            clientID: clientID,
            vaultSetupToken: vaultSetupToken,
            paymentSource: paymentSource
        )
        // swiftlint:disable indentation_width
        let queryString = """
                mutation UpdateVaultSetupToken(
                 $clientID: String!,
                    $vaultSetupToken: String!,
                    $paymentSource: PaymentSource
                ) {
                    updateVaultSetupToken(
                        clientId: $clientID
                        vaultSetupToken: $vaultSetupToken
                        paymentSource: $paymentSource
                    	) {
                            id,
                            status,
                            links {
                                rel, href
                            }
                        }
                }
                """
        self.query = queryString
    }
    // swiftlint:enable indentation_width
}
