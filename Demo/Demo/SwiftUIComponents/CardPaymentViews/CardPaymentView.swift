import SwiftUI

struct CardPaymentView: View {

    @StateObject var cardPaymentViewModel = CardPaymentViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CreateOrderCardPaymentView(
                    cardPaymentViewModel: cardPaymentViewModel,
                    selectedMerchantIntegration: DemoSettings.merchantIntegration
                )
                
                if let order = cardPaymentViewModel.state.createOrder {
                    OrderCreateCardPaymentResultView(cardPaymentViewModel: cardPaymentViewModel)
                    NavigationLink {
                        CardOrderApproveView(cardPaymentViewModel: cardPaymentViewModel, orderID: order.id)
                    } label: {
                        Text("Approve Order with Card")
                    }
                    .buttonStyle(RoundedBlueButtonStyle())
                    .padding()
                }
            }
        }
    }
}
