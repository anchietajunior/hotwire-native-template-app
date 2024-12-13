//
//  Endpoint.swift
//  HotTabs
//
//  Created by José Anchieta on 13/12/24.
//

import Foundation

struct Endpoint {
    static let remote = URL(string: "https://myremoteapp.com")!
    static let local = URL(string: "http://localhost:3000")!
    
    static var current: URL {
        local
    }
}
