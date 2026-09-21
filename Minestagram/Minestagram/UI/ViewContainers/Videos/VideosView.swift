import SwiftUI
import AVKit

struct VideosView: View {
    @StateObject private var viewModel = VideosViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.videos) { video in
                        NavigationLink(destination: VideoPlayerView(filename: video.filename)) {
                            VideoCardView(video: video)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("reels")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .yellow : .black)
                }
            }
            .toolbarBackground(colorScheme == .dark ? Color.black : Color.yellow, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct VideoCardView: View {
    let video: VideoItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [Color.black, Color(white: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 110)

            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.yellow)
                    .frame(width: 5, height: 70)
                    .padding(.leading, 16)

                VStack(alignment: .leading, spacing: 5) {
                    Text(video.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text("Minestagram Reels")
                        .font(.caption)
                        .foregroundColor(.yellow.opacity(0.8))
                }
                .padding(.leading, 12)

                Spacer()

                ZStack {
                    Circle().fill(Color.yellow).frame(width: 48, height: 48)
                    Image(systemName: "play.fill").foregroundColor(.black).font(.system(size: 18))
                }
                .padding(.trailing, 16)
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct VideoPlayerView: View {
    let filename: String

    var body: some View {
        if let url = Bundle.main.url(forResource: filename, withExtension: "mp4") {
            VideoPlayer(player: AVPlayer(url: url))
                .ignoresSafeArea()
        } else {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle").font(.largeTitle).foregroundColor(.orange)
                Text("Video '\(filename).mp4' not found in bundle.")
                    .multilineTextAlignment(.center).foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
