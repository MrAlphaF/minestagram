import Foundation
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    @Published var photoLocations = [PhotoLocation]()
    private let repo = MediaRepository()
    
    func loadMapData() {
        photoLocations = repo.getPhotoLocations()
    }
}
