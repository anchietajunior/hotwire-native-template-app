import HotwireNative
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let viewModel = TabBarViewModel(rootURL: Endpoint.current)

    private lazy var navigators: [Navigator] = viewModel.tabs.enumerated().map { createNavigator(tag: $0.offset) }
    private lazy var tabBarController = TabBarController(navigators: navigators, viewModel: viewModel)

    private func createNavigator(tag: Int) -> Navigator {
        let navigator = Navigator(pathConfiguration: viewModel.pathConfiguration, delegate: self)
        navigator.rootViewController.view.tag = tag
        return navigator
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.tabs.enumerated().forEach { index, tab in
                self.navigators[index].route(self.viewModel.rootURL.appendingPathComponent(tab.path))
            }
        }
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        print("🗨️ Proposal \(proposal)")

        let shouldHideNavbar = proposal.properties["hide_navbar"] as? Bool ?? false
        DispatchQueue.main.async {
            if let navController = self.tabBarController.selectedViewController as? UINavigationController {
                navController.setNavigationBarHidden(shouldHideNavbar, animated: true)
            }
        }
        return .accept
    }
}
