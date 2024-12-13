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
    
    private lazy var navigator = Navigator(pathConfiguration: pathConfiguration, delegate: self)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        window?.rootViewController = navigator.rootViewController
        navigator.route(rootURL)
    }
}

extension SceneDelegate: NavigatorDelegate {
    func handle(proposal: VisitProposal) -> ProposalResult {
        print("Proposal")
        print(proposal.properties)
        
        let shouldHideNavbar = proposal.properties["hide_navbar"] as? Bool ?? false
                
        if let navigationController = navigator.rootViewController as? UINavigationController {
            navigationController.setNavigationBarHidden(shouldHideNavbar, animated: true)
        }
        
        return .accept
    }
}
