//
//  SplashViewModel.swift
//  Oryen
//
//  Created by Erick Maicon Lima de Almeida on 16/12/25.
//

import SwiftUI
import Combine

final class SplashViewModel: ObservableObject {
    @Published var isActive: Bool = false
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation{
                self.isActive = true
            }
        }
    }
}
