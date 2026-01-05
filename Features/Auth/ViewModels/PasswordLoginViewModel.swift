import Foundation
import Combine
import FirebaseAuth

@MainActor
class PasswordLoginViewModel: ObservableObject {
    
    // MARK: - Propriedades de UI/Estado
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false // Gatilho para navegação para Home
    
    // MARK: - Dados do Contexto
    let userType: UserType
    let documentNumber: String
    private let authService = AuthService.shared
    
    // Recebemos o tipo e o documento da tela anterior
    init(userType: UserType, documentNumber: String) {
        self.userType = userType
        self.documentNumber = documentNumber
    }
    
    // MARK: - Helpers de UI (Oryen Style)
    
    var titleText: String {
        "Bem-vindo de volta!"
    }
    
    var subtitleText: String {
        // Personaliza a mensagem baseada no tipo, se quiser ser mais específico
        userType == .client
            ? "Digite sua senha para acessar sua conta pessoal."
            : "Digite a senha para acessar o painel da empresa."
    }
    
    var canProceed: Bool {
        !password.isEmpty && password.count >= 6
    }
    
    // MARK: - Ações de UI
    
    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
    
    // MARK: - Lógica de Login
    
    func login() async {
        // Validação prévia para economizar chamada de rede
        guard !password.isEmpty else {
            errorMessage = "Por favor, digite sua senha."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Limpeza do documento (Segurança extra)
            let cleanDoc = documentNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            
            // 2. Busca o E-mail vinculado ao CPF/CNPJ
            // Usamos a função unificada que criamos no AuthService
            let email = try await authService.getEmailByDocument(cleanDoc, type: userType)
            
            // 3. Autentica no Firebase Auth
            _ = try await authService.signIn(email: email, password: password)
            
            // 4. Sucesso -> Gatilho para navegar para a Home
            isAuthenticated = true
            
        } catch let error as AuthError {
            // Erros mapeados do nosso Enum
            errorMessage = error.errorDescription
        } catch {
            // Erros genéricos do Firebase ou Rede
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
