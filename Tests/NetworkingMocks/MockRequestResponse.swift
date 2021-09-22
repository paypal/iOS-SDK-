import Foundation

protocol MockRequestResponse {
    var responseData: Data? { get }
    var responseError: Error? { get }

    func canHandle(request: URLRequest) -> Bool
    func response(for request: URLRequest) -> HTTPURLResponse?
}
