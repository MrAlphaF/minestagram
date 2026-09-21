import Foundation

struct VideoItem: Identifiable {
    let id = UUID()
    let title: String
    let filename: String
}

@MainActor
class VideosViewModel: ObservableObject {
    @Published var videos: [VideoItem] = [
        VideoItem(title: "AK 47 vs AR 15", filename: "AKvAR")
    ]
}
