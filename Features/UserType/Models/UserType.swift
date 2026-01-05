import Foundation

enum UserType: String, Codable{
    case client = "cliente"
    case company = "empresa"
    
    var title: String{
        switch self {
        case .client:
            return "Sou Cliente"
        case .company:
            return "Sou Empresa"
        }
    }
    
    var description: String{
        switch self {
        case .client:
            return "Registrar novas reclamações e acompanhar o status dos seus pedidos."
        case .company:
            return "Gerenciar feedbacks, analisar métricas e responder aos seus clientes."
        }
    }
    
    var lottieFileName: String{
        switch self {
        case .client:
            return "Isometric Smartphone"
        case .company:
            return "Grficos aleatrios 1"
        }
    }
}
