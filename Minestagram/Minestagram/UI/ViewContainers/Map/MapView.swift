import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedLocation: PhotoLocation?
    @State private var showDialog = false

    var body: some View {
        NavigationStack {
            Map {
                ForEach(viewModel.photoLocations) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
                        VStack(spacing: 0) {
                            Image(systemName: "mappin.circle.fill").foregroundColor(.red).font(.title)
                            Text(location.name).font(.caption).fontWeight(.medium).fixedSize()
                        }
                        .onTapGesture {
                            selectedLocation = location
                            showDialog = true
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("geos")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .yellow : .black)
                }
            }
            .toolbarBackground(colorScheme == .dark ? Color.black : Color.yellow, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { viewModel.loadMapData() }
            .confirmationDialog("Navigate", isPresented: $showDialog, presenting: selectedLocation) { location in
                Button("Open in Apple Maps") {
                    let urlString = "maps://?saddr=&daddr=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                    if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
