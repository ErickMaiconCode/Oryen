import Foundation

struct ClientUser: Codable, Identifiable {
    var id: String?
    let cpf: String
    let name: String
    let email: String
    let phone: String
    let birthDate: Date
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case cpf
        case name
        case email
        case phone
        case birthDate
        case createdAt
    }
}
