//
//  BlockyApp.swift
//  Blocky
//
//  Created by Miru on 9/21/25.
//

import SwiftUI

@main
struct BlockyApp: App {
    @StateObject private var photoStore = PhotoStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(photoStore)
        }
    }
}
