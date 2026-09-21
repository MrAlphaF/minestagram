import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) var colorScheme

    // Each cell = exactly 1/3 of screen width, minus 2 x 1pt gaps
    private let spacing: CGFloat = 1
    private var cellSize: CGFloat {
        (UIScreen.main.bounds.width - spacing * 2) / 3
    }
    private var columns: [GridItem] {
        [GridItem(.fixed(cellSize), spacing: spacing),
         GridItem(.fixed(cellSize), spacing: spacing),
         GridItem(.fixed(cellSize), spacing: spacing)]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading && viewModel.user == nil {
                        ProgressView("Loading Profile...").padding()
                    } else if let user = viewModel.user {
                        UserProfileHeader(user: user)
                    }

                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(viewModel.photos) { photo in
                            NavigationLink(destination: PhotosDetailView(photoName: photo.name ?? "", user: viewModel.user)) {
                                LocalImageView(fileName: photo.name ?? "")
                                    .frame(width: cellSize, height: cellSize)
                                    .clipped()
                            }
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView("Loading Images...").padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("minestagram")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .yellow : .black)
                }
            }
            .toolbarBackground(colorScheme == .dark ? Color.black : Color.yellow, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task { await viewModel.loadData() }
        }
    }
}

struct UserProfileHeader: View {
    let user: User
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: { ProgressView() }
                .frame(width: 80, height: 80).clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Vārds:").font(.caption).foregroundColor(.secondary)
                    Text(user.name ?? "Unknown").font(.headline).foregroundColor(.primary)
                    Text("Uzņēmums:").font(.caption).foregroundColor(.secondary)
                    Text(user.company ?? "Unknown").font(.subheadline).foregroundColor(.primary)
                }
                Spacer()
            }
            .padding()

            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(12)
        .padding(12)
        .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct LocalImageView: View {
    let fileName: String
    var body: some View {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(fileName)

        if let uiImage = UIImage(contentsOfFile: url.path) {
            Image(uiImage: uiImage).resizable().scaledToFill()
        } else {
            Rectangle().fill(Color(.systemGray5))
        }
    }
}
