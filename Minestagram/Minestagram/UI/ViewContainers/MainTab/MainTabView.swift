import SwiftUI
import FirebaseRemoteConfig

enum Tab { case home, photo, video, map }

class TabController: ObservableObject {
    @Published var activeTab: Tab = .home
    @Published var showWhatsNew: Bool = false

    func fetchRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        // Set default values so the sheet shows even if Firebase is slow/offline
        remoteConfig.setDefaults(["showWhatsNew": true as NSObject])

        remoteConfig.fetchAndActivate { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.showWhatsNew = remoteConfig.configValue(forKey: "showWhatsNew").boolValue
            }
        }
    }
}

struct MainTabView: View {
    @StateObject private var tabController = TabController()

    var body: some View {
        TabView(selection: $tabController.activeTab) {
            HomeView().tag(Tab.home).tabItem { Label("", systemImage: "person.fill") }
            PhotosView().tag(Tab.photo).tabItem { Label("", systemImage: "photo") }
            VideosView().tag(Tab.video).tabItem { Label("", systemImage: "video.fill") }
            MapView().tag(Tab.map).tabItem { Label("", systemImage: "map.fill") }
        }
        .onAppear { tabController.fetchRemoteConfig() }
        .sheet(isPresented: $tabController.showWhatsNew) {
            WhatsNewView()
        }
    }
}

// MARK: - What's New Sheet
struct WhatsNewView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {

            // Yellow header bar
            ZStack {
                Color.yellow
                HStack {
                    Spacer()
                    Text("What's New")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button("Dismiss") { dismiss() }
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 50)

            // Section header
            HStack {
                Text("WHAT'S NEW IN MINESTAGRAM")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                Spacer()
            }

            // Feature rows
            VStack(spacing: 0) {
                WhatsNewRow(
                    icon: "photo.on.rectangle",
                    title: "Local Image Assets",
                    description: "Explore a wide range of stunning images added to our library."
                )
                Divider().padding(.leading, 56)

                WhatsNewRow(
                    icon: "play.rectangle",
                    title: "Local Video Assets",
                    description: "Discover new video content within our app for more entertainment."
                )
                Divider().padding(.leading, 56)

                WhatsNewRow(
                    icon: "map",
                    title: "Map with Points of Interest",
                    description: "Check out the map for points of interest where the loaded assets have been captured."
                )
                Divider().padding(.leading, 56)

                WhatsNewRow(
                    icon: "gearshape.2",
                    title: "Firebase Remote Config",
                    description: "Experience the new features and improvements powered by Firebase Remote Config."
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct WhatsNewRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 30)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
