import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var user: User?
    @Published var photos: [GHContent] = []
    @Published var isLoading: Bool = false

    private let userRepo = UserRepository()
    private let mediaRepo = MediaRepository()

    func loadData() async {
        guard photos.isEmpty else { return }
        isLoading = true

        do {
            user = try await userRepo.fetchUser()
        } catch {
            print("Failed to fetch user: \(error)")
        }

        // Fetch images from GitHub API (with bundle fallback)
        let urls = await mediaRepo.fetchAndCacheImages()
        for url in urls {
            try? await Task.sleep(nanoseconds: 75_000_000)
            photos.append(GHContent(name: url.lastPathComponent))
        }

        isLoading = false
    }
}
