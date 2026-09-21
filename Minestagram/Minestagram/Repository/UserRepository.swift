import Foundation

class UserRepository {
    func fetchUser() async throws -> User {
        let url = URL(string: "https://api.github.com/users/MrAlphaF")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(User.self, from: data)
    }
}
