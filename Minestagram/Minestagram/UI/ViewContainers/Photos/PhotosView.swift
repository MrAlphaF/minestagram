import SwiftUI

struct PhotosView: View {
    @StateObject private var viewModel = PhotosViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.photos) { photo in
                        NavigationLink(destination: PhotosDetailView(photoName: photo.name ?? "", user: viewModel.user)) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    AsyncImage(url: URL(string: viewModel.user?.avatarURL ?? "")) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: { Circle().fill(Color.gray) }
                                    .frame(width: 30, height: 30).clipShape(Circle())

                                    Text(viewModel.user?.name ?? "Loading...")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 6)

                                LocalImageView(fileName: photo.name ?? "")
                                    .frame(maxWidth: .infinity).aspectRatio(contentMode: .fit)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("posts")
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
