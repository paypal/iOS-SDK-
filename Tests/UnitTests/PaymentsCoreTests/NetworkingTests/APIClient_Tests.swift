import XCTest
@testable import PaymentsCore

class APIClient_Tests: XCTestCase {
    
    lazy var apiClient: APIClient = {
        APIClient(
            urlSession: URLSession(urlProtocol: URLProtocolMock.self),
            environment: .sandbox
        )
    }()

    func testFetch_withAccessTokenSuccessMockResponse_returnsValidAccessToken() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockSuccessResponse: String = """
        {
          "scope": "https://uri.paypal.com/services/invoicing",
          "access_token": "TestToken",
          "token_type": "Bearer",
          "expires_in": 29688,
          "nonce": "2021-09-13T15:00:23ZLpaHBzwLdATlXfE-G4NJsoxi9jPsYuMzOIE4u1TqDx8"
        }
        """

        URLProtocolMock.requestResponses.append(
            MockAccessTokenRequestResponse(responseString: mockSuccessResponse, statusCode: 200)
        )
        
        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, correlationID in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, "TestToken")
            case .failure(let error):
                XCTFail("Wrong mock response with error: \(error)")
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetch_withAccessTokenFailureMockResponse_returnsNoURLRequest() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockFailureResponse: String = """
        {
            "error": "unsupported_grant_type",
            "error_description": "unsupported grant_type"
        }
        """

        URLProtocolMock.requestResponses.append(
            MockAccessTokenRequestResponse(responseString: mockFailureResponse, statusCode: 404)
        )

        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, correlationID in
            switch result {
            case .success:
                XCTFail("Should not be able to successfully decode a result")
            case .failure(let error):
                XCTAssertNotNil(error)
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testFetch_withAccessTokenInvalidMockResponse_returnsDecodingError() {
        let expect = expectation(description: "Get mock response for access token request")

        let mockInvalidResponse: String = """
        {
            "test": "wrong response format"
        }
        """

        URLProtocolMock.requestResponses.append(
            MockAccessTokenRequestResponse(responseString: mockInvalidResponse, statusCode: 200)
        )

        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, correlationId in
            switch result {
            case .success:
                XCTFail("Should not succeed as the mock response has invalid format")
            case let .failure(error):
                guard case .decodingError(_) = error else {
                    XCTFail("Expect error to be NetworkingError.decodingError")
                    return
                }
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testParseDataObject_withNilData_throwsEmptyDataError() throws {
        XCTAssertThrowsError(
            try apiClient.parseDataObject(nil, type: AccessTokenRequest.self)
        ) { error in
            guard case NetworkingError.noResponseData = error else {
                XCTFail("Expected `NetworkingError.noResponseData`")
                return
            }
        }
    }

    func testFetch_withEmptyResponse_vendsSuccessfully() {
        let expect = expectation(description: "Get empty response type for mock request")

        let emptyRequest = MockEmptyRequest()

        URLProtocolMock.requestResponses.append(emptyRequest)

        apiClient.fetch(endpoint: emptyRequest) { result, _ in
            
            guard case .success(_) = result else {
                XCTFail("Expected successful empty response")
                return
            }
            expect.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}
