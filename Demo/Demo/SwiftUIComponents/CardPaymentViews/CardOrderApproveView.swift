import SwiftUI
import CardPayments
import CorePayments

struct CardOrderApproveView: View {

    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 25"
    @State private var cvvText: String = "123"
    let orderID: String
    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    let cardData: [CardSection] = [
        CardSection(title: "Step up", numbers: ["5314 6090 4083 0349"]),
        CardSection(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        CardSection(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        CardSection(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                HStack {
                    Text("Enter Card Information")
                        .font(.system(size: 20))
                    Spacer()
                }

                CardFormView(
                    cardNumberText: $cardNumberText,
                    expirationDateText: $expirationDateText,
                    cvvText: $cvvText,
                    cardSections: cardData
                )

                let card = Card.createCard(
                    cardNumber: cardNumberText,
                    expirationDate: expirationDateText,
                    cvv: cvvText
                )

                ZStack {
                    Button("Approve Order") {
                        Task {
                            do {
                                await cardPaymentViewModel.checkoutWith(card: card, orderID: orderID)
                            }
                        }
                    }
                    .buttonStyle(RoundedBlueButtonStyle())
                    if case .loading = cardPaymentViewModel.state.approveResultResponse {
                        CircularProgressView()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
                    .padding(5)
            )
            CardApprovalResultView(cardPaymentViewModel: cardPaymentViewModel)
            Spacer()
        }
        if cardPaymentViewModel.state.approveResult != nil {
            NavigationLink {
                CardPaymentOrderCompletionView(orderID: orderID, cardPaymentViewModel: cardPaymentViewModel)
            } label: {
                Text("Complete Order Transaction")
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()
        }
    }
}
