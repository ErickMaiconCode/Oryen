import Foundation
import Combine
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    
    // Propriedades
    @Published var userType: UserType
    @Published var documentNumber: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Navegação
    @Published var shouldNavigateToPassword = false
    @Published var shouldNavigateToRegister = false
    
    private let authService = AuthService.shared
    
    // Máscaras
    private let cpfMask = "###.###.###-##"
    private let cnpjMask = "##.###.###/####-##"
    
    init(userType: UserType) {
        self.userType = userType
    }
    
    // MARK: - Validação (A CORREÇÃO DO BOTÃO ESTÁ AQUI)
    var canProceed: Bool {
        // Remove tudo que não é número
        let clean = documentNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if userType == .client {
            return clean.count == 11 // CPF
        } else {
            return clean.count == 14 // CNPJ
        }
    }
    
    // MARK: - Formatação em Tempo Real
    func applyMask(_ raw: String) {
        // 1. Limpa
        let clean = raw.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // 2. Limita e Seleciona Máscara
        let limit = userType == .client ? 11 : 14
        let mask = userType == .client ? cpfMask : cnpjMask
        
        // 3. Corta excesso
        let limitedClean = String(clean.prefix(limit))
        
        // 4. Aplica máscara
        // Se você não tiver o MaskUtils.format, me avise que eu passo a função manual
        documentNumber = MaskUtils.format(text: limitedClean, mask: mask)
        
        if errorMessage != nil { errorMessage = nil }
    }
    
    // MARK: - Ações
    func validateDocument() async {
        guard canProceed else { return }
        isLoading = true
        errorMessage = nil
        
        let cleanDoc = documentNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        do {
            let exists: Bool
            if userType == .client {
                exists = try await authService.checkCPFExists(cleanDoc)
            } else {
                exists = try await authService.checkCNPJExists(cleanDoc)
            }
            
            if exists {
                shouldNavigateToPassword = true
            } else {
                shouldNavigateToRegister = true
            }
        } catch {
            errorMessage = "Erro de conexão. Tente novamente."
        }
        
        isLoading = false
    }
    
    // Labels de UI
    var titleText: String { userType == .client ? "Informe seu CPF" : "Informe seu CNPJ" }
    var documentLabel: String { userType == .client ? "CPF" : "CNPJ" }
    var documentPlaceholder: String { userType == .client ? "000.000.000-00" : "00.000.000/0000-00" }
    var documentIcon: String { userType == .client ? "person.text.rectangle" : "building.2" }
}
