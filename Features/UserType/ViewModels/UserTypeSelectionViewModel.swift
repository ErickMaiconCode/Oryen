import Foundation
import SwiftUI
import Combine

@MainActor
class UserTypeSelectionViewModel: ObservableObject {
    @Published var selectedUserType: UserType = .client
    
    // MARK: - Computed Properties
    var logoSize: CGFloat { 50 }
    
    var welcomeText: String { "Bem Vindo à" }
    
    var appNameGradientColors: [Color] {
        [Color("Cor Roxo"), Color("Cor Rosa"), Color("Cor Azul")]
    }
    
    var currentDescription: String {
        selectedUserType.description
    }
    
    var currentLottieFileName: String {
        selectedUserType.lottieFileName
    }
    
    var buttonTitle: String { "Continuar" }
    
    // MARK: - Actions
    func selectUserType(_ type: UserType) {
        selectedUserType = type
    }
    
    func saveAndContinue() {
        UserDefaults.standard.set(selectedUserType.rawValue, forKey: "selectedUserType")
    }
}
