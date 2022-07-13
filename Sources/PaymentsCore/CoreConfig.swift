import Foundation

/// The configuration object containing information required by every payment method.
/// It is used to initialize all Client objects.
public struct CoreConfig {

    public let clientID: String
    public let environment: Environment
    public let accessToken: String

    public init(clientID: String, accessToken:String, environment: Environment) {
        self.clientID = clientID
        self.environment = environment
        self.accessToken = accessToken
    }
}
