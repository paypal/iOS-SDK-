import SwiftUI
import CardPayments
import CorePayments

struct CardOrderApproveView: View {

    let cardSections: [CardSection] = [
        CardSection(title: "Successful Authentication Visa", numbers: ["4868 7194 6070 7704"]),
        CardSection(title: "Vault with Purchase (no 3DS)", numbers: ["4000 0000 0000 0002"]),
        CardSection(title: "Step up", numbers: ["5314 6090 4083 0349"]),
        CardSection(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        CardSection(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        CardSection(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]
    let orderID: String

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel
    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 27"
    @State private var cvvText: String = "123"

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Enter Card Information")
                                .font(.system(size: 20))
                            Spacer()
                        }

                        CardFormView(
                            cardSections: cardSections,
                            cardNumberText: $cardNumberText,
                            expirationDateText: $expirationDateText,
                            cvvText: $cvvText
                        )

                        let card = Card.createCard(
                            cardNumber: cardNumberText,
                            expirationDate: expirationDateText,
                            cvv: cvvText
                        )

                        Picker("SCA", selection: $cardPaymentViewModel.state.scaSelection) {
                            Text(SCA.scaWhenRequired.rawValue).tag(SCA.scaWhenRequired)
                            Text(SCA.scaAlways.rawValue).tag(SCA.scaAlways)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(height: 50)

                        ZStack {
                            Button("Approve Order") {
                                Task {
                                    do {
                                        await cardPaymentViewModel.checkoutWith(
                                            card: card,
                                            orderID: orderID,
                                            sca: cardPaymentViewModel.state.scaSelection
                                        )
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
                            .stroke(.gray, lineWidth: 2)
                            .padding(5)
                    )
                    CardApprovalResultView(cardPaymentViewModel: cardPaymentViewModel)
                    if cardPaymentViewModel.state.approveResult != nil {
                        NavigationLink {
                            CardPaymentOrderCompletionView(orderID: orderID, cardPaymentViewModel: cardPaymentViewModel)
                        } label: {
                            Text("Complete Order Transaction")
                        }
                        .buttonStyle(RoundedBlueButtonStyle())
                        .padding()
                    }
                    Text("")
                        .id("bottomView")
                    Spacer()
                }
                .onChange(of: cardPaymentViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}
