import SwiftUI
import FirebaseCore

@main
struct MinestagramApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
