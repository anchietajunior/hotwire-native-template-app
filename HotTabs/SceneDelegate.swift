//
//  SceneDelegate.swift
//  HotTabs
//
//  Created by José Anchieta on 13/12/24.
//

//
//  SceneDelegate.swift
//  HotTabs
//
//  Created by José Anchieta on 13/12/24.
//

import HotwireNative
import UIKit

let rootURL = URL(string: "http://localhost:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var pathConfiguration = PathConfiguration(sources: [
      .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
      .server(rootURL.appendingPathComponent("configurations/ios/v1.json"))
    ])
    
    private lazy var navigators: [Navigator] = {
            return [
                createNavigator(tag: 0),
                createNavigator(tag: 1),
                createNavigator(tag: 2)
            ]
        }()
    
    private lazy var tabBarController = TabBarController(navigators: navigators)
    
    private func createNavigator(tag: Int) -> Navigator {
            let navigator = Navigator(pathConfiguration: pathConfiguration, delegate: self)
            navigator.rootViewController.view.tag = tag
            return navigator
        }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Initial routing com delay para garantir que a UI esteja pronta
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.navigators[0].route(rootURL)
                    self.navigators[1].route(rootURL.appendingPathComponent("todos"))
                    self.navigators[2].route(rootURL.appendingPathComponent("pages/me"))
                }
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        print("Proposal")
        print(proposal.properties)
        
//        let shouldHideNavbar = proposal.properties["hide_navbar"] as? Bool ?? false
//
//        if let navigationController = navigator.rootViewController as? UINavigationController {
//            navigationController.setNavigationBarHidden(shouldHideNavbar, animated: true)
//        }
        
        return .accept
    }
    
    func willNavigate(visit: Visitable) {
            print("Will Navigate:")
        print("URL:", visit.visitableURL)
        print("Action:", visit.visitableViewController)
        }
        
    func didNavigate(visit: Visitable) {
            print("Did Navigate:")
            print("URL:", visit.visitableURL)
        }
    
}


class TabBarController: UITabBarController {
    private let navigators: [Navigator]
    
    init(navigators: [Navigator]) {
        self.navigators = navigators
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = navigators.map { $0.rootViewController }
        
        // Customize tab bar items
        viewControllers?[0].tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        viewControllers?[1].tabBarItem = UITabBarItem(title: "Posts", image: UIImage(systemName: "play.circle"), tag: 1)
        viewControllers?[2].tabBarItem = UITabBarItem(title: "Playlists", image: UIImage(systemName: "list.number"), tag: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
