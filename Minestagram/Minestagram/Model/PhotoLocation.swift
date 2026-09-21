import Foundation
import CoreLocation

struct PhotoLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
