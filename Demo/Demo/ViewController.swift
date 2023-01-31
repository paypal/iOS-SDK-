import UIKit
import CardPayments
import InAppSettingsKit
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }

        let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsTapped))
        navigationItem.rightBarButtonItem = settingsButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        displayDemoFeatureViewController()
    }

    @objc func settingsTapped() {
        let appSettingsViewController = IASKAppSettingsViewController()
        appSettingsViewController.showDoneButton = false
        navigationController?.pushViewController(appSettingsViewController, animated: true)
    }

    func displayDemoFeatureViewController() {
        removeChildViews()

        switch DemoSettings.demoUIFramework {
        case .uikit:
            let demoViewController = DemoSettings.demoType.viewController
            demoViewController.modalPresentationStyle = .fullScreen

            navigationItem.title = DemoSettings.demoType.rawValue.uppercased()

            addChild(demoViewController)
            view.addSubview(demoViewController.view)
        case .swiftui:
            let swiftUIController = UIHostingController(rootView: DemoSettings.demoType.swiftUIView)
            swiftUIController.view.translatesAutoresizingMaskIntoConstraints = false

            navigationItem.title = "SwiftUI - \(DemoSettings.demoType.rawValue.uppercased())"

            addChild(swiftUIController)
            view.addSubview(swiftUIController.view)

            NSLayoutConstraint.activate([
                swiftUIController.view.topAnchor.constraint(equalTo: view.topAnchor),
                swiftUIController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                swiftUIController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                swiftUIController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
}
