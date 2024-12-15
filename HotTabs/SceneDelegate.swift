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
        
        window = UIWindow(windowScene: scene as! UIWindowScene)
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
        print("Proposal: \(proposal.properties)")
        
        return .accept
    }
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    private let navigators: [Navigator]
    
    init(navigators: [Navigator]) {
        self.navigators = navigators
        super.init(nibName: nil, bundle: nil)
        
        viewControllers = navigators.map { $0.rootViewController }
        
        // Customize tab bar items
        viewControllers?[0].tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        viewControllers?[1].tabBarItem = UITabBarItem(title: "Posts", image: UIImage(systemName: "play.circle"), tag: 1)
        viewControllers?[2].tabBarItem = UITabBarItem(title: "Playlists", image: UIImage(systemName: "list.number"), tag: 2)
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        print("Tab selected at index:", index)
        
        // Realizar a navegação do Navigator correspondente
        let navigator = navigators[index]
        switch index {
        case 0:
            navigator.route(rootURL)
        case 1:
            navigator.route(rootURL.appendingPathComponent("todos"))
        case 2:
            navigator.route(rootURL.appendingPathComponent("pages/me"))
        default:
            break
        }
    }
}
