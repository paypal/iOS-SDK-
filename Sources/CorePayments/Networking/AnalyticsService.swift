import Foundation

/// Constructs `AnalyticsEventData` models and sends FPTI analytics events.
@_documentation(visibility: private)
public struct AnalyticsService {
    
    // MARK: - Internal Properties
    
    private let coreConfig: CoreConfig
    private let trackingEventsAPI: TrackingEventsAPI
    private let orderID: String
        
    // MARK: - Initializer
    
    public init(coreConfig: CoreConfig, orderID: String) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = TrackingEventsAPI(coreConfig: coreConfig)
        self.orderID = orderID
    }
    
    // MARK: - Internal Initializer

    /// Exposed for testing
    init(coreConfig: CoreConfig, orderID: String, trackingEventsAPI: TrackingEventsAPI) {
        self.coreConfig = coreConfig
        self.trackingEventsAPI = trackingEventsAPI
        self.orderID = orderID
    }
    
    // MARK: - Public Methods
        
    /// This method is exposed for internal PayPal use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Sends analytics event to https://api.paypal.com/v1/tracking/events/ via a background task.
    /// - Parameter name: Event name string used to identify this unique event in FPTI.
    public func sendEvent(_ name: String) {
        Task(priority: .background) {
            await performEventRequest(name)
        }
    }
    
    // MARK: - Internal Methods
    
    /// Exposed to be able to execute this function synchronously in unit tests
    func performEventRequest(_ name: String) async {
        do {
            let clientID = coreConfig.clientID
            
            let eventData = AnalyticsEventData(
                environment: coreConfig.environment.toString,
                eventName: name,
                clientID: clientID,
                orderID: orderID
            )
            
            let (_) = try await trackingEventsAPI.sendEvent(with: eventData)
        } catch {
            NSLog("[PayPal SDK] Failed to send analytics: %@", error.localizedDescription)
        }
    }
}
