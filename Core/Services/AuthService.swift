import FirebaseAuth
import FirebaseFirestore

enum AuthError: LocalizedError {
    case userNotFound
    case invalidCredentials
    case weakPassword
    case emailAlreadyInUse
    case documentNotFound
    case unknown(String)
    
    var errorDescription: String? {
        switch self{
        case .userNotFound:
            return "Usuário não encontrado. Deseja criar uma conta?"
            
        case .invalidCredentials:
            return "E-mail ou senha inválidos."
            
        case .weakPassword:
            return "A senha deve conter pelo menos 6 caracteres."
            
        case .emailAlreadyInUse:
            return "O e-mail fornecido já está sendo usado por outra conta."
            
        case .documentNotFound:
            return "CPF/CNPJ não encontrado."
            
        case .unknown(let message):
            return message
        }
    }
}

class AuthService {
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init(){}
    
    // Verificar se o CPF já existe
    func checkCPFExists(_ cpf: String) async throws -> Bool {
            let cleanCPF = cpf.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let snapshot = try await db.collection("users") // Unifiquei collection para users ou mantenha clients se preferir
                .whereField("cpf", isEqualTo: cleanCPF)
                .getDocuments()
            return !snapshot.documents.isEmpty
        }
    
    // Verificar se o CNPJ existe
    func checkCNPJExists(_ cnpj: String) async throws -> Bool {
            let cleanCNPJ = cnpj.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let snapshot = try await db.collection("companies")
                .whereField("cnpj", isEqualTo: cleanCNPJ)
                .getDocuments()
            return !snapshot.documents.isEmpty
        }
    
    // Buscar email por CPF
    func getEmailByDocument(_ document: String, type: UserType) async throws -> String {
            let cleanDoc = document.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            let field = type == .client ? "cpf" : "cnpj"
            
            let snapshot = try await db.collection("users")
                .whereField(field, isEqualTo: cleanDoc)
                .getDocuments()
        
        
            
            guard let doc = snapshot.documents.first,
                  let email = doc.data()["email"] as? String else {
                throw AuthError.userNotFound
            }
            return email
        }

        func checkEmailExists(_ email: String) async throws -> Bool {
            let cleanEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
            
            // 1. Check A: Verifica se existe perfil no Firestore
            let usersSnapshot = try await db.collection("users").whereField("email", isEqualTo: cleanEmail).getDocuments()
            if !usersSnapshot.documents.isEmpty { return true }
                    

            let companiesSnapshot = try await db.collection("companies").whereField("corporateEmail", isEqualTo: cleanEmail).getDocuments()
            if !companiesSnapshot.documents.isEmpty { return true }
            
            // 2. Check B: Verifica se existe credencial no Auth
            do {
                let signInMethods = try await Auth.auth().fetchSignInMethods(forEmail: cleanEmail)
                if !signInMethods.isEmpty {
                    return true
                }
            }
            return false
        }
    
    // Fazer Login
    func signIn(email: String, password: String) async throws -> String {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user.uid
        }
    
    // Registrar Cliente
    func registerClient(_ client: ClientUser, password: String) async throws -> String {
        // Criar usuário no Firebase Auth
        let result = try await auth.createUser(withEmail: client.email, password: password)
        let uid = result.user.uid
        
        // Salvar dados no Firestore
        var clientData = client
        clientData.id = uid
        
        try await db.collection("clients").document(uid).setData([
            "id": uid,
            "cpf": client.cpf,
            "name": client.name,
            "email": client.email,
            "phone": client.phone,
            "birthDate": Timestamp(date: client.birthDate),
            "createdAt": Timestamp(date: client.createdAt)
        ])
        
        return uid
    }
    
    // Registrar Empresa
    func registerEnterprise(_ company: CompanyUser, password: String) async throws -> String {
        let result = try await auth.createUser(withEmail: company.corporateEmail, password: password)
        let uid = result.user.uid
        
        var companyData = company
        companyData.id = uid
        
        try await db.collection("companies").document(uid).setData([
            "id": uid,
            "cnpj": company.cnpj,
            "legalName": company.legalName,
            "tradeName": company.tradeName,
            "corporateEmail": company.corporateEmail,
            "segment": company.segment,
            "companySize": company.companySize.rawValue,
            "responsibleRole": company.responsibleRole,
            "corporatePhone": company.corporatePhone,
            "createdAt": Timestamp(date: company.createdAt)
        ])
        return uid
    }
    
    // Logout
    func signOut() throws {
        try auth.signOut()
    }
}

