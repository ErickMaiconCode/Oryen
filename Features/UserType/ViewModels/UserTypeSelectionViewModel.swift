
import Foundation
import Combine

class UserTypeSelectionViewModel: ObservableObject {
    @Published var selectedUserType: UserType = .client
    
    func selectUserType(_ type: UserType) {
        selectedUserType = type
    }
    
    func saveAndContinue() {
        UserDefaults.standard.set(selectedUserType.rawValue, forKey: "selectedUserType")
    }
}
