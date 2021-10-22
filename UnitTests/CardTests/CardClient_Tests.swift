import XCTest
@testable import PaymentsCore
@testable import Card
@testable import TestShared

final class CardClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let card = Card(
        number: "411111111111",
        expirationMonth: "01",
        expirationYear: "2021",
        securityCode: "123"
    )
    let config = CoreConfig(clientID: "", environment: .sandbox)

    // swiftlint:disable implicitly_unwrapped_optional
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    var cardClient: CardClient!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()

        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil

        apiClient = APIClient(urlSession: mockURLSession, environment: .sandbox)
        cardClient = CardClient(config: config, apiClient: apiClient)
    }

    // MARK: - approveOrder() tests

    func testApproveOrder_withValidJSONRequest_returnsOrderData() {
        let expect = expectation(description: "Callback invoked.")

        let jsonResponse = """
        {
            "id": "testOrderID",
            "status": "APPROVED",
            "payment_source": {
                "card": {
                    "last_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT"
                }
            }
        }
        """

        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = jsonResponse

        cardClient.approveOrder(orderID: "", card: card) { result in
            switch result {
            case .success(let orderData):
                XCTAssertEqual(orderData.orderID, "testOrderID")
                XCTAssertEqual(orderData.status, .approved)
            case .failure:
                XCTFail()
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testApproveOrder_withInvalidJSONResponse_returnsParseError() throws {
        let expect = expectation(description: "Callback invoked.")

        let jsonResponse = """
        {
            "some_unexpected_response": "something"
        }
        """

        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = jsonResponse

        cardClient.approveOrder(orderID: "", card: card) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error.domain, APIClientError.domain)
                XCTAssertEqual(error.code, APIClientError.Code.dataParsingError.rawValue)
                XCTAssertEqual(error.localizedDescription, "An error occured parsing HTTP response data. Contact developer.paypal.com/support.")
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
