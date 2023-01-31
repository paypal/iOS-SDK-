import Foundation
@testable import PaymentsCore

class MockURLSession: URLSessionProtocol {

    var cannedError: Error?
    var cannedURLResponse: URLResponse?
    var cannedJSONData: String?

    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if let error = cannedError {
            throw error
        } else {
            guard let data = cannedJSONData?.data(using: String.Encoding.utf8) else { fatalError("error") }
            guard let urlResponse = cannedURLResponse else { fatalError("error") }
            return (data, urlResponse)
        }
    }
}
