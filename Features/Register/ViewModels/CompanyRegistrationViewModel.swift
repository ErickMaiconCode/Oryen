import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

enum CompanyRegistrationStep: Int, CaseIterable {
    case cnpj, basicInfo, details, contact, password
    
    var title: String {
            switch self {
            case .cnpj: return "Identificação"
            case .basicInfo: return "Dados da Empresa"
            case .details: return "Detalhes do Negócio"
            case .contact: return "Canais de Contato"
            case .password: return "Segurança"
            }
        }
    
    var subtitle: String {
        switch self{
        case .cnpj: return "Comece informando o CNPJ da sua empresa"
        case .basicInfo: return "Razão Social e Nome Fantasia"
        case .details: return "Tamanho e segmento de atuação"
        case .contact: return "E-mail corporativo e telefone principal"
        case .password: return "Crie uma senha robusta"
        }
    }
}

@MainActor
class CompanyRegistrationViewModel: ObservableObject {
    
    // MARK: - Dados da Empresa
    @Published var cnpj: String = ""
    @Published var legalName: String = ""
    @Published var tradeName: String = ""
    @Published var segment: String = ""
    @Published var selectedSize: CompanySize = .micro
    @Published var responsibleRole: String = ""
    @Published var corporateEmail: String = ""
    @Published var corporatePhone: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    // MARK: - Estado
    @Published var currentStep: CompanyRegistrationStep = .cnpj{
        didSet{ errorMessage = nil }
    }
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistered = false
    
    init(initialCNPJ: String? = nil) {
        if let cnpj = initialCNPJ, !cnpj.isEmpty {
            self.cnpj = cnpj
            self.currentStep = .basicInfo
        } else{
            self.currentStep = .cnpj
        }
    }
    
    // MARK: - Helpers
    func applyCNPJMask(_ raw: String){
        let clean = raw.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let limit = String(clean.prefix(14))
        cnpj = MaskUtils.formatCNPJ(limit)
    }
    
    func applyPhoneMask(_ raw: String){
        let clean = raw.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let limit = String(clean.prefix(11))
        corporatePhone = MaskUtils.format(text: limit, mask: "(##) #####-####")
    }
    
    var isStepValid: Bool {
            switch currentStep {
            case .cnpj:
                let clean = cnpj.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                return Validator.isValidCNPJ(clean)
                
            case .basicInfo:
                return legalName.count >= 5 && tradeName.count >= 2
                
            case .details:
                return !segment.isEmpty && !responsibleRole.isEmpty
                
            case .contact:
                return corporateEmail.contains("@") && corporateEmail.contains(".") && corporatePhone.filter{$0.isNumber}.count >= 10
                
            case .password:
                return password.count >= 6
            }
        }
    
    func nextStep(){
        guard isStepValid else { return }
        switch currentStep {
        case .cnpj:
            performCNPJCheck()
        case .contact:
            performEmailCheck()
        case .password:
            registerCompany()
        default:
            advanceToNextStep()
        }
    }
    
    func previousStep() {
        withAnimation {
            if let prev = CompanyRegistrationStep(rawValue: currentStep.rawValue - 1) {
                currentStep = prev
            }
        }
    }
    
    private func advanceToNextStep(){
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)){
            if let next = CompanyRegistrationStep(rawValue: currentStep.rawValue + 1) {
                currentStep = next
            }
        }
    }
    
    private func performCNPJCheck(){
        isLoading = true
        errorMessage = nil
        let cleanCNPJ = cnpj.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        Task{
            do{
                let exists = try await AuthService.shared.checkCNPJExists(cleanCNPJ)
                isLoading = false
                
                if exists {
                    errorMessage = "Este CNPJ já possui cadastro na plataforma"
                } else{
                    advanceToNextStep()
                }
            } catch {
                isLoading = false
                errorMessage = "Ocorreu um erro ao verificar o CNPJ. Tente novamente."
            }
        }
    }
    
    private func performEmailCheck(){
        isLoading = true
        errorMessage = nil
        let cleanEmail = corporateEmail.lowercased().trimmingCharacters(in: .whitespaces)
        
        Task{
            do{
                let exists = try await AuthService.shared.checkEmailExists(corporateEmail)
                isLoading = false
                
                if exists {
                    errorMessage = "Este e-mail já está sendo usado. Faça login."
                } else{
                    advanceToNextStep()
                }
            } catch {
                isLoading = false
                errorMessage = "Erro de conexão"
            }
        }
    }
    
    private func registerCompany() {
            guard password == confirmPassword else {
                errorMessage = "As senhas não coincidem."
                return
            }
            
            isLoading = true
            errorMessage = nil
            
            // Monta o objeto CompanyUser
            let newCompany = CompanyUser(
                id: nil,
                cnpj: cnpj.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression),
                legalName: legalName,
                tradeName: tradeName,
                corporateEmail: corporateEmail.lowercased().trimmingCharacters(in: .whitespaces),
                segment: segment,
                companySize: selectedSize,
                responsibleRole: responsibleRole,
                corporatePhone: corporatePhone.filter { $0.isNumber },
                createdAt: Date()
            )
            
            Task {
                do {
                    let _ = try await AuthService.shared.registerEnterprise(newCompany, password: password)
                    isLoading = false
                    isRegistered = true
                    
                } catch {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

