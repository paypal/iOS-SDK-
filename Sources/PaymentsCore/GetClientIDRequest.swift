import Foundation

struct GetClientIDRequest: APIRequest {

    typealias ResponseType = GetClientIDResponse

    let path: String = "v1/oauth2/token"
    let token: String
    var method: HTTPMethod = .get
    var body: Data?

    var headers: [HTTPHeader: String] {
        [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer \(token)"
        ]
    }

    /// Creates request to get the order information
    init(token: String) {
        self.token = token
    }
}
