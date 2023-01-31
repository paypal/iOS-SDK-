# Pay using PaymentButtons

1. [Add PaymentButtons](#add-payment-buttons)

## Add Payment Buttons

### 1. Add the PaymentButtons to your app

#### Swift Package Manager

In Xcode, follow the guide to [add package dependencies to your app](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) and enter https://github.com/paypal/iOS-SDK as the repository URL. Select the checkboxes for each specific PayPal library you wish to include in your project.

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PaymentButtons
```

#### CocoaPods

Include the PayPal pod in your `Podfile`.

```ruby
pod 'PayPal'
```

In your app's source files, use the following import syntax to include PayPal's libraries:

```swift
import PaymentButtons
```

### 2. Render PayPal buttons
The PayPalUI module allows you to render three buttons that can offer a set of customizations like color, edges, size and labels:
* `PayPalButton`: generic PayPal button
* `PayPalPayLater`: a PayPal button with a fixed PayLater label
* `PayPalCredit`: a PayPal button with the PayPalCredit logo

Each button as a `UKit` and `SwiftUI` implementation as follows:

    | UIKit      | SwiftUI |
    | ----------- | ----------- |
    | PayPalButton      | PayPalButton.Representable       |
    | PayPalCreditButton   | PayPalCreditButton.Representable        |
    | PayPalPayLaterButton   | PayPalPayLaterButton.Representable        |
> Note: label customization only applies to `PayPalButton` when its size is `.expanded` or `.full`

#### UKit

```swift
class MyViewController: ViewController {

    lazy var payPalButton: PayPalButton = {
        let payPalButton = PayPalButton()
        payPalButton.addTarget(self, action: #selector(payPalButtonTapped), for: .touchUpInside)
        return payPalButton
    }()
    
    @objc func paymentButtonTapped() {
        // Insert your code here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(payPalButton)
    }
}
```

#### SwiftUI

```swift
struct MyApp: View {
    @ViewBuilder
    var body: some View {
        VStack {
            PayPalButton.Representable() {
                // Insert your code here
            }
        }
    }
}
```
