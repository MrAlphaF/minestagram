import Foundation

struct GHContent: Codable, Identifiable, Hashable {
    let id = UUID()
    var name: String?
    var downloadURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case downloadURL = "download_url"
    }
}
