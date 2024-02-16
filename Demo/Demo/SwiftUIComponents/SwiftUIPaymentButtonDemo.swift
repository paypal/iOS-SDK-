import SwiftUI
import PaymentButtons

struct SwiftUIPaymentButtonDemo: View {

    @State private var pickerID = 0
    @State private var buttonID = 0

    @State private var fundingIndex = 0
    private var fundingSources = PaymentButtonFundingSource.allCasesAsString()
    @State private var selectedFunding = PaymentButtonFundingSource.allCases[0]

    @State private var colorsIndex = 0
    @State private var colors = PayPalButton.Color.allCasesAsString()

    @State private var shapeIndex = 0
    private var shape = PaymentButtonShape.allCasesAsString()
    @State private var selectedShape = PaymentButtonShape.allCases[0]
    @State private var customCornerRadius: Int = 10

    @State private var sizesIndex = 1
    private var sizes = PaymentButtonSize.allCasesAsString()
    @State private var selectedSize = PaymentButtonSize.allCases[1]
    
    @State private var labelIndex = 0
    private var labels = PayPalButton.Label.allCasesAsString()
    @State private var selectedLabel = PayPalButton.Label.allCases[0]

    @ViewBuilder var body: some View {
        ZStack {
            VStack {
                Text("Note: Button colors have been consolidated and deprecated to gold and white. Other colors will be removed in v2.")
                    .font(.footnote)

                Picker("Funding Source", selection: $fundingIndex) {
                    ForEach(fundingSources.indices, id: \.self) { index in
                        Text(fundingSources[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: fundingIndex) { _ in
                    selectedFunding = PaymentButtonFundingSource.allCases[fundingIndex]
                    colors = getColorFunding(with: selectedFunding)
                    colorsIndex = 0
                    pickerID += 1 // Workaround to change ID of picker. ID is updated to force refresh, https://developer.apple.com/forums/thread/127560
                    buttonID += 1
                }

                Picker("Colors", selection: $colorsIndex) {
                    ForEach(colors.indices, id: \.self) { index in
                        Text(colors[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: colorsIndex) { _ in
                    buttonID += 1
                }
                .id(pickerID)

                Picker("Shape", selection: $shapeIndex) {
                    ForEach(shape.indices, id: \.self) { index in
                        Text(shape[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: shapeIndex) { _ in
                    selectedShape = PaymentButtonShape.allCases[shapeIndex]
                    buttonID += 1
                }
                Stepper(
                    "Custom Corner Radius: \(customCornerRadius)",
                    value: $customCornerRadius,
                    in: 0...100).onChange(of: customCornerRadius) { _ in
                    if selectedShape.description == "custom" {
                        selectedShape = PaymentButtonShape.custom(CGFloat(customCornerRadius))
                        buttonID += 1
                    }
                }
                Picker("sizes", selection: $sizesIndex) {
                    ForEach(sizes.indices, id: \.self) { index in
                        Text(sizes[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: sizesIndex) { _ in
                    selectedSize = PaymentButtonSize.allCases[sizesIndex]
                    buttonID += 1
                }

                switch selectedFunding {
                case .payPal:
                    if selectedSize == .standard {
                        Picker("Shape", selection: $shapeIndex) {
                            ForEach(shape.indices, id: \.self) { index in
                                Text(shape[index])
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: shapeIndex) { _ in
                            selectedShape = PaymentButtonShape.allCases[shapeIndex]
                            buttonID += 1
                        }

                        Picker("label", selection: $labelIndex) {
                            ForEach(labels.indices, id: \.self) { index in
                                Text(labels[index])
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .onChange(of: labelIndex) { _ in
                            selectedLabel = PayPalButton.Label.allCases[labelIndex]
                            buttonID += 1
                        }
                    }
                    PayPalButton.Representable(
                        color: PayPalButton.Color.allCases[colorsIndex],
                        shape: selectedShape,
                        size: selectedSize,
                        label: selectedLabel
                    )
                    .id(buttonID)
                    .frame(maxWidth: .infinity)

                case .payLater:
                    PayPalPayLaterButton.Representable(
                        color: PayPalPayLaterButton.Color.allCases[colorsIndex],
                        shape: selectedShape,
                        size: selectedSize
                    )
                    .id(buttonID)

                case .credit:
                    PayPalCreditButton.Representable(
                        color: PayPalCreditButton.Color.allCases[colorsIndex],
                        shape: selectedShape,
                        size: selectedSize
                    )
                    .id(buttonID)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private func getColorFunding(with funding: PaymentButtonFundingSource) -> [String] {
        switch funding {
        case .payPal:
            return PayPalButton.Color.allCasesAsString()

        case .payLater:
            return PayPalPayLaterButton.Color.allCasesAsString()

        case .credit:
            return PayPalCreditButton.Color.allCasesAsString()
        }
    }
}

struct SwiftUIPaymentButtonDemo_Preview: PreviewProvider {
    
    static var previews: some View {
        SwiftUIPaymentButtonDemo()
    }
}
