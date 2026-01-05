
import Foundation

enum CompanySize: String, Codable, CaseIterable {
    case micro = "Microempresa (até 19 funcionários)"
    case small = "Pequena empresa (20-99 funcionários)"
    case medium = "Média empresa (100-499 funcionários)"
    case large = "Grande empresa (500+ funcionários)"
}

struct CompanyUser: Codable, Identifiable {
    var id: String?
    let cnpj: String
    let legalName: String
    let tradeName: String
    let corporateEmail: String
    let segment: String
    let companySize: CompanySize
    let responsibleRole: String
    let corporatePhone: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case cnpj
        case legalName
        case tradeName
        case corporateEmail
        case segment
        case companySize
        case responsibleRole
        case corporatePhone
        case createdAt
    }
}
