struct CreateOrderParams: Codable {

    let intent: String
    var purchaseUnits: [PurchaseUnit]?
    var applicationContext: ApplicationContext?
}

struct PurchaseUnit: Codable {

    let amount: Amount
}

struct Amount: Codable {

    let currencyCode: String
    let value: String
}

struct ApplicationContext: Codable {

    var returnUrl: String?
    var cancelUrl: String?
}
