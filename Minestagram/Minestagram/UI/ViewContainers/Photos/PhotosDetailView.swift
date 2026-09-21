import SwiftUI

struct PhotosDetailView: View {
    let photoName: String
    let user: User?
    @State private var dateTaken: String = "Loading..."
    @State private var isLiked: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    AsyncImage(url: URL(string: user?.avatarURL ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color(.systemGray4))
                    }
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 1) {
                        Text(user?.login ?? "armandsberzins")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        Text(dateTaken)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "ellipsis").foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                LocalImageView(fileName: photoName)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(contentMode: .fit)

                HStack(spacing: 20) {
                    Button { isLiked.toggle() } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(isLiked ? .red : .primary)
                    }
                    Image(systemName: "bubble.right").font(.title2).foregroundColor(.primary)
                    Image(systemName: "paperplane").font(.title2).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "bookmark").font(.title2).foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Text(isLiked ? "43 likes" : "42 likes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.top, 6)

                HStack(alignment: .top, spacing: 4) {
                    Text(user?.login ?? "armandsberzins")
                        .font(.system(size: 14, weight: .semibold))
                    Text("📍 Tatra Mountains")
                        .font(.system(size: 14))
                }
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top, 2)
                .padding(.bottom, 16)
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
        .onAppear {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = docs.appendingPathComponent(photoName)
            if let exif = MediaRepository().getExif(fromURL: url), let dt = exif.dateTaken {
                dateTaken = dt
            } else {
                dateTaken = "Nav EXIF datu"
            }
        }
    }
}
