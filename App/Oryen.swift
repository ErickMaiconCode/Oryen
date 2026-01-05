//
//  OryenApp.swift
//  Oryen
//
//  Created by Erick Maicon Lima de Almeida on 15/12/25.
//

import SwiftUI
import Firebase

@main
struct OryenApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppEntryView()
        }
    }
}
