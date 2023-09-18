import SwiftUI

struct CardVaultView: View {

    @StateObject var cardVaultViewModel = CardVaultViewModel()

    // MARK: Views

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateSetupTokenView(
                        selectedMerchantIntegration: DemoSettings.merchantIntegration,
                        cardVaultViewModel: cardVaultViewModel
                    )
                    SetupTokenResultView(cardVaultViewModel: cardVaultViewModel)
                    if let setupToken = cardVaultViewModel.state.setupToken {
                        UpdateSetupTokenView(cardVaultViewModel: cardVaultViewModel, setupToken: setupToken.id)
                    }
                    UpdateSetupTokenResultView(cardVaultViewModel: cardVaultViewModel)
                    if let updateSetupToken = cardVaultViewModel.state.updateSetupToken {
                        CreatePaymentTokenView(
                            cardVaultViewModel: cardVaultViewModel,
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            setupToken: updateSetupToken.id
                        )
                    }
                    PaymentTokenResultView(cardVaultViewModel: cardVaultViewModel)
                    switch cardVaultViewModel.state.paymentTokenResponse {
                    case .loaded, .error:
                        VStack {
                            Button("Reset") {
                                cardVaultViewModel.resetState()
                            }
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.gray)
                            .cornerRadius(10)
                        }
                        .padding(5)
                    default:
                        EmptyView()
                    }
                    Text("")
                        .id("bottomView")
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.horizontal, 10)
                        .onChange(of: cardVaultViewModel.state) { _ in
                            withAnimation {
                                scrollView.scrollTo("bottomView")
                            }
                        }
                }
            }
        }
    }
}

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
