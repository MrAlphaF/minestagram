import Foundation

struct User: Codable {
    let id: Int
    let login: String?
    let avatarURL: String?
    let name: String?
    let company: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, company, bio
        case avatarURL = "avatar_url"
    }
}
