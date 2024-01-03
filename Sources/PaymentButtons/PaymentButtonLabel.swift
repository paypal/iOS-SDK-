import Foundation

/// The label displayed next to PaymentButton's logo.
public enum PaymentButtonLabel: String {

<<<<<<< HEAD
    /// Use on a website or app where the term ‘add money’ is used for a customer adding money to an account.
    /// Add label to the left of the PayPal logo.
    case addMoneyWith = "Add Money with"

    /// Use on product detail pages where customers are reserving an experience or service.
    /// Add label to the left of the PayPal logo.
    case bookWith = "Book with"

    /// Recommended for use on product detail pages to help give customers context on the resulting action.
    /// Add label to the left of the PayPal logo.
    case buyWith = "Buy with"

    /// Add label to the left of the PayPal logo.
    case buyNowWith = "Buy Now with"


    /// Recommended for use on cart and checkout pages, where there is a purchasing context. Add label to the left of the PayPal logo.
    case checkoutWith = "Checkout with"

    /// Use as the call to action on a checkout page when PayPal is the selected payment method, and
    /// the customer will return to the website or app to complete the purchase. Add label to the left of the PayPal logo.
    case continueWith = "Continue with"

    /// Add "Contribute" to the left of the PayPal logo. Add label to the left of the PayPal logo.
    case contributeWith = "Contribue with"

    /// Use on a website or app where a customer is placing an order, commonly associated with food purchases.
    /// Add label to the left of the PayPal logo.
    case orderWith = "Order with"

    /// Add "Pay later" to the right of button's logo, only used for PayPalPayLaterButton.
    /// Add label to the right of the PayPal logo.
    case payLater = "Pay Later"

    /// Add label to the left of the PayPal logo.
    case payLaterWith = "Pay Later with"

    /// Recommended for use on pages where customers are paying bills or invoices. Add label to the left of the PayPal logo.
    case payWith = "Pay with"

    /// Use on a website or app where the term ‘reload’ is used for a customer adding money to an account.
    /// Add label to the left of the PayPal logo.
    case reloadWith = "Reload with"

    /// Use when a customer is renting an item. Add label to the left of the PayPal logo.
    case rentWith = "Rent with"

    /// Add label to the left of the PayPal logo.
    case reserveWith = "Reserve with"

    /// Use when a customer will start opt in to recurring payments to your store. Add label to the left of the PayPal logo.
    case subscribeWith = "Subscribe with"

    /// Add "Support with" to the left of the PayPal logo. Add label to the left of the PayPal logo.
    case supportWith = "Support with"

    /// Use when a customer is tipping for an item or service. Add label to the left of the PayPal logo.
    case tipWith = "Tip with"

    /// Use on a website or app where the term ‘top up’ is used for a customer adding money to an account.
    /// Add label to the left of the PayPal logo.
    case topUpWith = "Top Up with"
=======
    /// Recommended for use on cart and checkout pages, where there is a purchasing context.
    case checkoutWith = "Checkout with"

    /// Recommended for use on product detail pages to help give customers context on the resulting action.
    case buyWith = "Buy with"

    ///
    case buyNowWith = "Buy Now with"

    ///Use on product detail pages where customers are reserving an experience or service.
    /// Add "Buy Now" to the left of button's logo
    case bookWith = "Book with"

    ///
    case reserveWith = "Reserve with"

    /// Use as the call to action on a checkout page when PayPal is the selected payment method, and
    /// the customer will return to the website or app to complete the purchase.
    case continueWith = "Continue with"

    /// Use on a website or app where the term ‘reload’ is used for a customer adding money to an account.
    case reloadWith = "Reload with"

    /// Use on a website or app where the term ‘add money’ is used for a customer adding money to an account.
    case addMoneyWith = "Add Money with"

    /// Use on a website or app where the term ‘top up’ is used for a customer adding money to an account.
    case topUpWith = "Top Up with"

    /// Use on a website or app where a customer is placing an order, commonly associated with food purchases.
    case orderWith = "Order with"

    /// Use when a customer is renting an item.
    case rentWith = "Rent with"

    ///
    case supportWith = "Support with"

    ///
    case contributeWith = "Contribue with"

    /// Use when a customer is tipping for an item or service.
    case tipWith = "Tip with"

    /// Recommended for use on pages where customers are paying bills or invoices.
    case payWith = "Pay with"

    /// Use when a customer will start opt in to recurring payments to your store.
    case subscribeWith = "Subscribe with"

    /// Add "Pay later" to the right of button's logo, only used for PayPalPayLaterButton
    case payLater = "Pay Later"
>>>>>>> 1bd84e6 (Added new button labels)

    /// Add "Pay later" to the right of button's logo, only used for PayPalPayLaterButton
    case payLaterWith = "Pay Later with"

    enum Position {
        case prefix
        case suffix
    }

    var position: Position {
        switch self {
<<<<<<< HEAD
        case .checkoutWith,
=======
        case .checkoutWith, 
>>>>>>> 1bd84e6 (Added new button labels)
                .buyWith,
                .buyNowWith,
                .bookWith,
                .reserveWith,
                .continueWith,
                .reloadWith,
                .addMoneyWith,
                .topUpWith,
                .orderWith,
                .rentWith,
                .supportWith,
<<<<<<< HEAD
                .contributeWith,
=======
                .contributeWith, 
>>>>>>> 1bd84e6 (Added new button labels)
                .tipWith,
                .payWith,
                .subscribeWith,
                .payLaterWith:
<<<<<<< HEAD
            return .prefix

        case .payLater:
            return .suffix

=======
            return .suffix

        case .payLater:
            return .prefix
>>>>>>> 1bd84e6 (Added new button labels)
        }
    }
}
