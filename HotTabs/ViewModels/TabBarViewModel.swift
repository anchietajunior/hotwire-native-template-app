import Foundation
import HotwireNative

class TabBarViewModel {
    private(set) var tabs: [Tab]
    let rootURL: URL
    let pathConfiguration: PathConfiguration

    init(rootURL: URL) {
        self.rootURL = rootURL
        self.tabs = [
            Tab(title: "Home", icon: "house", path: ""),
            Tab(title: "Posts", icon: "list.number", path: "todos"),
            Tab(title: "Playlists", icon: "person", path: "pages/me")
        ]
        self.pathConfiguration = PathConfiguration(sources: [
            .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")!),
            .server(rootURL.appendingPathComponent("configurations/ios/v1.json"))
        ])
    }
}
