import UIKit
import HotwireNative

class TabBarController: UITabBarController {
    private let navigators: [Navigator]
    private let viewModel: TabBarViewModel

    init(navigators: [Navigator], viewModel: TabBarViewModel) {
        self.navigators = navigators
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        viewControllers = navigators.map { $0.rootViewController }
        viewControllers?.enumerated().forEach { index, controller in
            let tab = viewModel.tabs[index]
            controller.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.icon),
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

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        let tab = viewModel.tabs[index]
        navigators[index].route(viewModel.rootURL.appendingPathComponent(tab.path))
    }
}
