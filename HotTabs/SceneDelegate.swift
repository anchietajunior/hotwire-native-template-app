//
//  SceneDelegate.swift
//  HotTabs
//
//  Created by José Anchieta on 13/12/24.
//

import HotwireNative
import UIKit

// MARK: - Constants
private enum Constants {
    static let rootURL = URL(string: "http://localhost:3000")!
    
    enum Tab {
        static let items: [(title: String, icon: String, path: String)] = [
            ("Home", "house", ""),
            ("Posts", "list.number", "todos"),
            ("Playlists", "person", "pages/me")
        ]
    }
}

// MARK: - SceneDelegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var pathConfiguration = PathConfiguration(sources: [
        .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
        .server(Constants.rootURL.appendingPathComponent("configurations/ios/v1.json"))
    ])
    
    private lazy var navigators: [Navigator] = (0..<Constants.Tab.items.count).map { createNavigator(tag: $0) }
    private lazy var tabBarController = TabBarController(navigators: navigators)
    
    private func createNavigator(tag: Int) -> Navigator {
        let navigator = Navigator(pathConfiguration: pathConfiguration, delegate: self)
        navigator.rootViewController.view.tag = tag
        return navigator
    }
    
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
          guard let windowScene = scene as? UIWindowScene else { return }
          
          window = UIWindow(windowScene: windowScene)
          window?.rootViewController = tabBarController
          window?.makeKeyAndVisible()
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              self.navigators.forEach { navigator in
                  if let navController = navigator.rootViewController as? UINavigationController {
                      navController.setNavigationBarHidden(false, animated: false)
                  }
              }
              
              self.navigators.enumerated().forEach { index, navigator in
                  let path = Constants.Tab.items[index].path
                  navigator.route(Constants.rootURL.appendingPathComponent(path))
              }
          }
      }
}

// MARK: - NavigatorDelegate
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

// MARK: - TabBarController
class TabBarController: UITabBarController {
    private let navigators: [Navigator]
    
    init(navigators: [Navigator]) {
        self.navigators = navigators
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = navigators.map { $0.rootViewController }
        
        viewControllers?.enumerated().forEach { index, controller in
            let item = Constants.Tab.items[index]
            controller.tabBarItem = UITabBarItem(
                title: item.title,
                image: UIImage(systemName: item.icon),
                tag: index
            )
        }
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers?.forEach { viewController in
            (viewController as? UINavigationController)?.setNavigationBarHidden(false, animated: false)
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        let path = Constants.Tab.items[index].path
        navigators[index].route(Constants.rootURL.appendingPathComponent(path))
    }
}
