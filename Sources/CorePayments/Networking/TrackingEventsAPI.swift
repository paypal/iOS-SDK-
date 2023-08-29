import Foundation

/// This class coordinates networking logic for communicating with the v1/tracking/events API.
///
/// Details on this PayPal API can be found in PPaaS under Infrastructure > Experimentation > Tracking Events > v1.
class TrackingEventsAPI {
        
    // MARK: - Internal Properties

    var coreConfig: CoreConfig // exposed for testing
    private var apiClient: APIClient

    // MARK: - Initializer
    
    init(coreConfig merchantConfig: CoreConfig) {
        // api.sandbox.paypal.com does not currently send FPTI events to BigQuery/Looker
        self.coreConfig = CoreConfig(clientID: merchantConfig.clientID, environment: .live)
        self.apiClient = APIClient(coreConfig: coreConfig)
    }
    
    /// Exposed for injecting MockAPIClient in tests
    init(coreConfig: CoreConfig, apiClient: APIClient) {
        self.coreConfig = coreConfig
        self.apiClient = apiClient
    }
    
    // MARK: - Internal Functions
        
    func sendEvent(with analyticsEventData: AnalyticsEventData) async throws -> HTTPResponse {
        let restRequest = RESTRequest(
            path: "v1/tracking/events",
            method: .post,
            queryParameters: nil,
            postParameters: analyticsEventData
        )
        
        return try await apiClient.fetch(request: restRequest)
    }
}
