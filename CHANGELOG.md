
# PayPal iOS SDK Release Notes

## unreleased
* CardPayments
  * Add `vault`property in `CardRequest`, this type contains a `customerID`, if a customer ID is not provided one will be generated  
* PayPalNativePayments
  * Bump `PayPalCheckout` to `1.0.0`
  
## 0.0.9 (2023-06-23)
* Breaking Changes
  * CardPayments
    * Remove `status` property from `CardResult`
    * Remove `paymentSource` property from `CardResult`
  * CorePayments
    * CoreConfig instances must now be instantiated using a `clientID` instead of an `accessToken`

## 0.0.8 (2023-05-08)
* PayPalNativePayments
  * Add `PayPalNativePaysheetActions` to `PayPalNativeShippingDelegate.didShippingAddressChange()` and `PayPalNativeShippingDelegate.didShippingMethodChange()`
* Card
  * Rename `Card.init()` parameter from `cardHolderName` to `cardholderName`
  * Remove unnecessary `Card.expiry` property
* CorePayments
  * Send `orderID` instead of `sessionID` for analytics

## 0.0.7 (2023-03-28)
* PayPalNativePayments
  * Update `PayPalNativeCheckoutDelegate.paypal(_:didFinishWithResult:)` to use `PayPalNativeCheckoutResult` instead of `PayPalCheckout.Approval` type.
  * Update `PayPalNativeCheckoutClient.start(presentingViewController:createOrder)` to `PayPalNativeCheckoutClient.start(request:presentingViewController:)`
    * Require `PayPalNativeCheckoutRequest` param instead of `PayPalCheckout.CheckoutConfig.CreateOrderCallback`
  * Add `PayPalNativeShippingDelegate` as optional delegate on `PayPalNativeCheckoutClient`
    * Add `PayPalNativeShippingDelegate.didShippingAddressChange()`
    * Add `PayPalNativeShippingDelegate.didShippingMethodChange()`
    * Remove `PayPalNativeCheckoutDelegate.paypalDidShippingAddressChange()`
  * Update `PayPalNativeCheckoutDelegate.paypal(_:didFinishWithResult:)` to use `PayPalNativeCheckoutResult` instead of `PayPalCheckout.Approval` type.

## 0.0.6 (2023-02-21)
* Fix CocoaPods build error for Xcode 13

## 0.0.5 (2023-02-21)
* Rename `PaymentsCore` to `CorePayments`
* Rename `PayPalDataCollector` to `FraudProtection`
* Rename `PayPalNativeCheckout` to `PayPalNativePayments`
* Rename `PayPalWebCheckout` to `PayPalWebPayments`
* Rename `PayPalUI` to `PaymentButtons`
* Rename `Card` to `CardPayments`
* PayPalUI
    * Fix issue where label was not being shown
* Rename `Environment.production` enum case to `Environment.live`
* Send analytic events for `PayPalNativePayments`, `PayPalWebPayments`, and `CardPayments` flows

## 0.0.4 (2023-01-17)
* Card
  * Remove `ThreeDSecureRequest` from `CardRequest` and create URLs internally 
  * Update `CardRequest` to optionally pass `sca`
  * Remove step requiring `ASWebAuthenticationPresentationContextProviding` conformance
* PayPalWebCheckout
  * Remove step requiring `ASWebAuthenticationPresentationContextProviding` conformance
* PayPalUI
  * Fix assets not rendering when importing with Swift Package Manager and CocoaPods

## 0.0.3 (2022-11-03)
* PayPalNativeCheckout
    * Expose PayPalNativeCheckout through Swift Package Manager

## 0.0.2 (2022-11-03)
* PayPalUI
    * Fix fatal crash with iOS 16: `UIViewRepresentables must be value types`. Separate buttons into `UIKit` and `SwiftUI` implementations.
    
    | UIKit      | SwiftUI |
    | ----------- | ----------- |
    | PayPalButton      | PayPalButton.Representable       |
    | PayPalCreditButton   | PayPalCreditButton.Representable        |
    | PayPalPayLaterButton   | PayPalPayLaterButton.Representable        |
    
* PayPalNativeCheckout
    * Update to version 0.109.0 that fixes shipping callback bug
* Bump minimum supported deployment target to iOS 14+
* Require Xcode 14
    * Bump Swift Tools Version to 5.7 for CocoaPods & SPM

## 0.0.1 (2022-07-21)

* Card
  * Add `Address`
  * Add `Card`
  * Add `CardClient`
  * Add `CardRequest`
  * Add `CardResult`
  
* PayPalCheckout
  * Add `PayPalWebCheckout`
  
* PayPalUI
  * Add `PayPalButton` Button
  * Add `PayPalPayLater` Button
  * Add `PayPalCredit` Button

* PayPalDataCollector
  * Add `PayPalDataCollector`
  * Add `MagnesSDK`
