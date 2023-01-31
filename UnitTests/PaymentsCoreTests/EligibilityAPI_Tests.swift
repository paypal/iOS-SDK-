import XCTest
@testable import CorePayments
@testable import TestShared

class EligibilityAPI_Tests: XCTestCase {

    let mockClientID = "mockClientId"
    let mockAccessToken = "mockAccessToken"
    let mockURLSession = MockURLSession()
    // swiftlint:disable implicitly_unwrapped_optional
    var coreConfig: CoreConfig!
    var graphQLClient: GraphQLClient!
    var eligibilityAPI: EligibilityAPI!
    var apiClient: MockAPIClient!

    // swiftlint:enable implicitly_unwrapped_optional
    override func setUp() {
        super.setUp()
        coreConfig = CoreConfig(accessToken: mockAccessToken, environment: .sandbox)
        apiClient = MockAPIClient(coreConfig: coreConfig)
        graphQLClient = GraphQLClient(environment: .sandbox, urlSession: mockURLSession)
    }

    func testCheckEligibilityWithSuccessResponse() async throws {
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "454532"]
        )
        mockURLSession.cannedJSONData = validFundingEligibilityResponse
        eligibilityAPI = EligibilityAPI(coreConfig: coreConfig, apiClient: apiClient, graphQLClient: graphQLClient)
        let result = try await eligibilityAPI.checkEligibility()
        switch result {
        case .success(let eligibility):
            XCTAssertTrue(eligibility.isVenmoEligible)
            XCTAssertTrue(eligibility.isPaypalEligible)
            XCTAssertFalse(eligibility.isCreditCardEligible)
        case .failure(let error):
            XCTAssertNil(error)
        }
    }
    func testCheckEligibilityErrorResponse() async throws {
        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "454532"]
        )
        mockURLSession.cannedJSONData = notValidFundingEligibilityResponse
        eligibilityAPI = EligibilityAPI(coreConfig: coreConfig, apiClient: apiClient, graphQLClient: graphQLClient)
        let result = try await eligibilityAPI.checkEligibility()
        switch result {
        case .success(let eligibility):
            XCTAssertNil(eligibility)
        case .failure(let failure):
            XCTAssertNotNil(failure)
        }
    }
    let notValidFundingEligibilityResponse = """
        {

        }
    """
    let validFundingEligibilityResponse = """
        {
            "data": {
            "fundingEligibility": {
                "venmo": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible",
                        "VENMO OPT-IN WITH ENABLE_FUNDING"
                    ]
                },
                "card": {
                    "eligible": false
                },
                "paypal": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible"
                    ]
                },
                "paylater": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible",
                        "CRC OFFERS SERV CALLED: Trmt_xo_xobuyernodeserv_call_crcoffersserv",
                        "CRC OFFERS SERV ELIGIBLE"
                    ]
                },
                "credit": {
                    "eligible": false,
                    "reasons": [
                        "INELIGIBLE DUE TO PAYLATER ELIGIBLE"
                    ]
                }
            }
        }
        }
        """
}
