//
//  NavigationApp.swift
//  Navigation
//
//  Created by Maxim Krimskiy on 4/6/21.
//

import SwiftUI

@main
struct NavigationApp: App {
    @StateObject var GlobalState = GlobalStateController()

    var body: some Scene {
        WindowGroup {
            Init().environmentObject(GlobalState)

        }
    }
}
