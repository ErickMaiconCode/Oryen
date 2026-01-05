import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

enum RegistrationStep: Int, CaseIterable {
    case name, email, phone, birthDate, password, confirmPassword
    
    var title: String {
        switch self {
        case .name: return "Vamos começar"
        case .email: return "Seu melhor e-mail"
        case .phone: return "Contato telefônico"
        case .birthDate: return "Data de nascimento"
        case .password: return "Segurança"
        case .confirmPassword: return "Confirmação"
        }
    }
    
    var subtitle: String {
        switch self {
        case .name: return "Como podemos chamar você ou sua empresa?"
        case .email: return "Enviaremos atualizações importantes por lá."
        case .phone: return "Usaremos para validar sua conta se necessário."
        case .birthDate: return "Precisamos confirmar que você é maior de 18 anos."
        case .password: return "Crie uma senha forte com letras e números."
        case .confirmPassword: return "Repita a senha para garantir que não houve erro."
        }
    }
}

@MainActor
class ClientRegistrationViewModel: ObservableObject {
    
    // MARK: - Dados
    let cpf: String
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var birthDate: Date = {
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    // MARK: - Estado
    @Published var currentStep: RegistrationStep = .name {
        didSet {
            errorMessage = nil
        }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistered = false
    
    init(cpf: String) {
        self.cpf = cpf
    }
    
    // MARK: - Máscara de Telefone
    func applyPhoneMask(_ raw: String) {
        let clean = MaskUtils.clean(raw)
        let limit = String(clean.prefix(11))
        phone = MaskUtils.format(text: limit, mask: "(##) #####-####")
    }
    
    // MARK: - Lógica de Força de Senha (0 a 6 pontos)
    var passwordStrengthScore: Int {
        var score = 0
        
        if password.count >= 4 { score += 1 }
        
        if password.count >= 6 { score += 1 }
        
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        
        if password.count >= 8 { score += 1 }
        
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?€£¥₹")
        if password.rangeOfCharacter(from: specialCharacters) != nil { score += 1 }
        
        return score
    }
    
    var passwordStrengthColor: Color {
        switch passwordStrengthScore {
        case 0...2: return .red      // Fraca
        case 3...4: return .orange   // Média
        case 5...6: return .green    // Forte
        default: return .gray
        }
    }
    
    var passwordStrengthLabel: String {
        switch passwordStrengthScore {
        case 0...1: return "Muito Fraca"
        case 2: return "Fraca"
        case 3: return "Razoável"
        case 4: return "Boa"
        case 5: return "Forte"
        case 6: return "Excelente"
        default: return ""
        }
    }
    
    // Validações Booleanas para o Checklist Visual
    var hasMinLength: Bool { password.count >= 6 }
    var hasNumber: Bool { password.rangeOfCharacter(from: .decimalDigits) != nil }
    var hasUppercase: Bool { password.rangeOfCharacter(from: .uppercaseLetters) != nil }
    
    // MARK: - Lógica de Data
    var maximumBirthDate: Date {
        let today = Date()
        let eighteenYearsAgo = Calendar.current.date(byAdding: .year, value: -18, to: today) ?? today
        return Calendar.current.startOfDay(for: eighteenYearsAgo)
    }
    
    var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()
        
        // Data Mínima: 01/01/1900 (Ninguém mais velho que isso vai usar o app)
        let minDate = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1)) ?? Date()
        
        // Data Máxima: Hoje - 18 anos
        // Usamos 'endOfDay' para garantir que qualquer hora do dia limite seja aceita
        let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: today) ?? today
        let maxDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: eighteenYearsAgo) ?? eighteenYearsAgo
        
        return minDate...maxDate
    }
    
    // MARK: - Validações
    var isStepValid: Bool {
        switch currentStep {
        case .name:
            return name.trimmingCharacters(in: .whitespaces).count >= 3
        case .email:
            return email.contains("@") && email.contains(".") && email.count > 5
        case .phone:
            return phone.filter { $0.isNumber }.count >= 10
        case .birthDate:
            return dateRange.contains(birthDate)
        case .password:
            return passwordStrengthScore >= 6
        case .confirmPassword:
            return !confirmPassword.isEmpty && confirmPassword == password
        }
    }
    
    func nextStep() {
            // 1. Validação básica (O campo está preenchido corretamente?)
            guard isStepValid else { return }
            
            // 2. Roteamento: Decide o que fazer com base na tela atual
            switch currentStep {
                
            case .email:
                // Se for email, chama a verificação de banco (Assíncrona/Bloqueante)
                performEmailCheck()
                
            case .confirmPassword:
                // Se for o fim, registra
                registerUser()
                
            default:
                // Para qualquer outro passo (Nome, Telefone, Data), apenas avança
                advanceToNextStep()
            }
        }
        
        // MARK: - Funções Auxiliares (Os "Operários")
        
        // 1. Função que APENAS avança a tela (UI)
        private func advanceToNextStep() {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                if let next = RegistrationStep(rawValue: currentStep.rawValue + 1) {
                    currentStep = next
                }
            }
        }
        
        // 2. Função que APENAS verifica o email (Lógica de Negócio)
        private func performEmailCheck() {
            isLoading = true
            errorMessage = nil
            
            Task {
                do {
                    // Chama o serviço
                    let exists = try await AuthService.shared.checkEmailExists(email)
                    
                    // Finaliza loading
                    isLoading = false
                    
                    if exists {
                        // Cenario de Erro: Trava e mostra mensagem
                        errorMessage = "Este e-mail já está sendo usado. Faça login."
                    } else {
                        // Cenário de Sucesso: Chama o operário que avança a tela
                        advanceToNextStep()
                    }
                } catch {
                    isLoading = false
                    errorMessage = "Erro de conexão. Verifique sua internet."
                }
            }
        }
    
    func previousStep() {
        withAnimation {
            if let prev = RegistrationStep(rawValue: currentStep.rawValue - 1) {
                currentStep = prev
            }
        }
    }
    
    private func registerUser() {
        isLoading = true
        errorMessage = nil
        
        let cleanEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
        
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: cleanEmail , password: password)
                let uid = authResult.user.uid
                
                let userData: [String: Any] = [
                    "uid": uid,
                    "cpf": cpf,
                    "name": name,
                    "email": email,
                    "phone": phone.filter { $0.isNumber },
                    "birthDate": Timestamp(date: birthDate),
                    "userType": "client",
                    "createdAt": FieldValue.serverTimestamp()
                ]
                
                try await Firestore.firestore().collection("users").document(uid).setData(userData)
                
                isLoading = false
                isRegistered = true
                
            } catch {
                isLoading = false
                errorMessage = handleAuthError(error)
            }
        }
    }
    private func handleAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        
        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return "Erro desconhecido: \(error.localizedDescription)"
        }
        
        switch errorCode {
        case .emailAlreadyInUse:
            return "Este e-mail já está cadastrado em outra conta."
            
        case .invalidEmail:
            return "O formato do e-mail é inválido."
            
        case .weakPassword:
            return "A senha é muito fraca. Use letras, números e símbolos."
            
        case .networkError:
            return "Sem conexão com a internet. Verifique seu Wi-Fi/Dados."
            
        case .userNotFound:
            return "Conta não encontrada."
            
        case .wrongPassword:
            return "Senha incorreta."
            
        case .operationNotAllowed:
            return "Esta operação não é permitida no momento."
            
        case .tooManyRequests:
            return "Muitas tentativas. Tente novamente mais tarde."
            
        default:
            return "Erro ao realizar operação: \(error.localizedDescription)"
        }
    }
}
